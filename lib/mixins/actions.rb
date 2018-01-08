require 'active_support/concern'
require 'util/errors'
require 'helpers/params_helper'
require 'helpers/errors_helper'

module JsonapiCrud
  module Actions extend ActiveSupport::Concern

    include JsonapiCrud::ParamsHelper
    include JsonapiCrud::ErrorsHelper

    attr_reader :response_obj,
                :current_obj

    REQUIRE_CURRENT_OBJ = [:show, :update, :destroy, :restore]
    included do
      before_action :set_current_obj, :only => [*REQUIRE_CURRENT_OBJ]
    end

    def model_class
      controller_name.classify
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

    def set_current_obj
      source = request.method == "DELETE" ? model.with_deleted : model
      if params.has_key? model_id
        @current_obj = source.find params[model_id]
      else
        @current_obj = source.find params[:id]
      end
    rescue ActiveRecord::RecordNotFound
      render_error Error.not_found({:id => params[:id]} )
    end

    def build_relationships
      return if p_relationships.nil?

      p_relationships.each do |key, relationship|
        attribute = key.jsonapi_underscore
        data = p_data(relationship)
        if data.kind_of?(Array)
          ids = data.map { |item| item[:id] }
          value = attribute.classify.constantize.where(id: [ids])
        else
          id = data[:id]
          value = attribute.classify.constantize.find_by(id: id)
        end
        @current_obj.send("#{attribute}=", value) unless value.nil?
      end
    end

    def index
      if params.has_key?(model_ids)
        objs = model.where(id: params[model_ids])
        @response_obj = ::JsonapiCrud::ResponseObject.new(obj: objs)
      else
        @response_obj = ::JsonapiCrud::ResponseObject.new(obj: model.all)
      end

      render_response
    end

    def show
      @response_obj = ::JsonapiCrud::ResponseObject.new(obj: @current_obj, include: p_include) #, meta: "roles"
      render_response
    end

    def create
      @current_obj = model.new(valid_params)
      build_relationships
      _create(@current_obj) do
        create_success
      end
    end

    def _create(obj, &on_success)
      if obj.save
        @response_obj = ::JsonapiCrud::ResponseObject.new(obj: obj, status: :created)
        on_success.call if on_success.present?
        render_response
      else
        compile_errors(obj)
      end
    end

    def update
      build_relationships
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
      if p_meta.present? && p_meta.has_key?(:hard_delete) && p_meta[:hard_delete].to_bool
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
      if obj.really_destroy!
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
      render :json => @response_obj.obj, **@response_obj.options
    end

    #abstract

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
    end

  end
end
