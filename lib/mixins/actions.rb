require 'active_support/concern'
require 'util/errors'
require 'helpers/params_helper'
require 'helpers/errors_helper'
require 'helpers/validations_helper'

module JsonapiCrud
  module Actions extend ActiveSupport::Concern

    include JsonapiCrud::ParamsHelper
    include JsonapiCrud::ErrorsHelper

    attr_reader :response_obj,
                :current_obj,
                :include


    REQUIRE_CURRENT_OBJ = [:show, :update, :destroy, :restore]
    included do
      before_action :set_current_obj, :only => [*REQUIRE_CURRENT_OBJ]
    end

    def dynamic_model?
      false
    end

    def include
      @include ||= []
    end

    def model_class
      type = controller_name
      if dynamic_model?
        if params[:data].present? && p_data[:type].present?
          type = p_data[:type].singularize
        elsif params[:type].present?
          type = params[:type]
        end
      end
      type.jsonapi_underscore.classify
    end

    def model
      model_class.constantize
    end

    def model_id
      model_class.downcase + "_id"
    end

    def model_ids
      model_id + "s"
    end

    def paranoid?
      model.new.attributes.keys.include? "deleted_at"
    end

    def set_current_obj
      source = request.method == "DELETE" && paranoid? ? model.with_deleted : model
      if params.has_key? model_id
        @current_obj = source.find params[model_id]
      else
        @current_obj = source.find params[:id]
      end
    rescue ActiveRecord::RecordNotFound
      render_error Error.not_found({:id => params[:id]} )
    end

    def create_related_models(key, related_model, ids)
      records = []
      ids.each do |id|
        included = p_included(key.pluralize, id)
        if included.present? && included.count == 1
          obj = related_model.new(included.first[:attributes].permit(*related_model.valid_attributes))
          build_relationships(obj, included.first[:relationships])
          if obj.save
            self.include << key.jsonapi_underscore
            records << obj
          else
            # obj.errors.each do |attribute, error|
            #   Rails.logger.info " -- #{attribute} #{error}"
            # end
          end
        end
      end
      records
    end

    def build_relationships(obj, relationships)
      return if relationships.nil?
      relationships.each do |key, relationship|
        attribute = key.jsonapi_underscore
        next unless obj.can_relate?(attribute)
        related_attribute = attribute
        data = p_data(relationship)

        begin
          if data[:type].present? && relationship.present?
            related_attribute = data[:type].singularize
          end
          related_model = related_attribute.classify.constantize
        rescue => ex
          next
        end

        if data.kind_of?(Array)
          ids = data.map { |item| item[:id] }
          records = related_model.where(id: [ids])
          value = records + create_related_models(key, related_model, ids - records.map{|r| r.id})
        else
          id = data[:id]

          value = related_model.find_by(id: id)
          if value.nil?
            value = create_related_models(key, related_model, [id]).first
          end
        end
        obj.send("#{attribute}=", value) unless value.nil?
      end
    end

    def index
      if params.has_key?(model_ids)
        objs = model.where(id: params[model_ids])
        @response_obj = ::JsonapiCrud::ResponseObject.new(obj: objs, include: p_include)
      else
        @response_obj = ::JsonapiCrud::ResponseObject.new(obj: model.all, include: p_include)
      end

      render_response
    end

    def show
      @response_obj = ::JsonapiCrud::ResponseObject.new(obj: @current_obj, include: p_include) #, meta: "roles"
      render_response
    end

    def create
      @current_obj = model.new(valid_params)
      build_relationships(@current_obj, p_relationships)
      _create(@current_obj) do
        create_success
      end
    end

    def _create(obj, &on_success)
      if obj.save
        Rails.logger.info "include: #{@include} #{self.include}"
        @response_obj = ::JsonapiCrud::ResponseObject.new(obj: obj, status: :created, include: @include) #
        on_success.call if on_success.present?
        render_response
      else
        compile_errors(obj)
      end
    end

    def update
      build_relationships(@current_obj, p_relationships)
      _update(@current_obj) do
        update_success
      end
    end

    def _update(obj, update_params = valid_params, &on_success)
      obj.update_timestamps(nil, p_attributes[:updated_at]) if p_attributes.present?
      if obj.update(update_params)
        @response_obj = ::JsonapiCrud::ResponseObject.new(:obj => obj)
        on_success.call if on_success.present?
        render_response
      else
        compile_errors(obj)
      end
    end

    def destroy
      if !paranoid? || (params[:hard_delete].present? && params[:hard_delete].to_bool)
        hard_destroy(@current_obj) do
          hard_destroy_success
        end
      else
        soft_destroy(@current_obj) do
          soft_destroy_success
        end
      end
    end

    def soft_destroy(obj, &on_success)
      if obj.deleted? || obj.destroy
        @response_obj = ::JsonapiCrud::ResponseObject.new(obj: obj, status: :ok)
        on_success.call if on_success.present?
        render_response
      else
        compile_errors(obj)
      end
    end

    def hard_destroy(obj, &on_success)
      destroy_method = paranoid? ? "really_destroy!" : "destroy"
      if obj.send(destroy_method)
        @response_obj = ::JsonapiCrud::ResponseObject.new(obj: nil, status: :no_content)
        on_success.call if on_success.present?
        render_response
      else
        compile_errors(obj)
      end
    end

    def restore
      _restore(@current_obj) do
        restore_success
      end
    end

    def _restore(obj, &on_success)
      if obj.restore
        @response_obj = ::JsonapiCrud::ResponseObject.new(obj: obj, status: :ok)
        on_success.call if on_success.present?
        render_response
      else
        compile_errors(obj)
      end
    end

    def compile_errors(obj)
      obj.errors.each do |attribute, error|
        ::JsonapiCrud::Errors.add( Error.invalid_attribute(attribute, error) )
      end
      render_errors
    end

    def render_response
      before_render
      # Rails.logger.info "@response_obj.options: #{@response_obj.options}"
      render :json => @response_obj.obj, **@response_obj.options
    end

    #abstract

    def before_render
    end

    def create_success
    end

    def update_success
    end

    def soft_destroy_success
    end

    def hard_destroy_success
    end

    def restore_success
    end

    def valid_params
      p_attributes.permit(*model.valid_attributes)
    end

    # def valid_relationships
    #   model.serialized_relationships
    # end

    # def can_relate?(obj, key)
    #   type ||= model
    #   return false if params[:action] == "update" && !can_update_relationships?
    #   a = type.serialized_relationships #valid_relationships || []
    #   if a.is_a?(Hash)
    #     a = a[params[:action].to_sym] || []
    #   end
    #   a.include?(key.to_sym)
    # end

  end
end
