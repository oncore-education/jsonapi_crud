require Rails.root.join('spec/support/jsonapi_crud/helpers/json_helper.rb')

module JsonapiCrud

  class SharedDataSource

    include JsonapiCrud::JsonResponse


    attr_accessor :options

    def set_options(opts = {})
      self.options = opts
    end

    def base_route
      "/v1/#{model_type.jsonapi_underscore}"
    end

    def model
      model_type.jsonapi_underscore.classify.constantize
    end

    def model_factory
      model_type.jsonapi_underscore.singularize.to_sym
    end

    # `base_route` needs to be defined in mixin
    def base_url(id = "", action = nil)
      route = base_route + "/" + id.to_s
      if action.present?
        route += "/" + action
      end
      route
    end

    # `model` needs to be defined in mixin
    def index_count
      model.count
    end

    def model_type

    end

    def eval_node(node)
      return if !node.is_a?(Hash)
      node.each do |key, value|
        if value.is_a?(String) && value.start_with?("options[")
          value.replace eval(value).to_s
        elsif value.is_a?(Hash)
          eval_node(value)
        end
      end
    end

    def eval_params(p)
      eval_node(p)
      p
    end

    def create_requests
      [ {:params => create_params, :expects => expected_create_attributes} ]
    end

    #formats the params into the json:api spec
    #def formatted_params(attributes, id = nil, meta = nil)
    def formatted_params(options = {})
      data = options
      data[:type] = model_type if model_type.present?

      {:data => data}
    end

    def delete_params(id, hard = false)
      formatted_params(:id => id, :meta => {:hard_delete => hard} )
    end

    # this is an empty object that will be used to
    # make sure not including a `data` object will fail.
    # It is defined as a method so mixins can overwrite it
    def missing_data_params
      default_params
    end

    def default_params
      { }
    end

    def expected_soft_delete_attributes
        [{:json_obj => JsonResponse::ATTRIBUTES, :key => 'deleted-at', :type_check => 'not nil'}]
    end

    def create_req
      'auth_req'
    end

  end
end