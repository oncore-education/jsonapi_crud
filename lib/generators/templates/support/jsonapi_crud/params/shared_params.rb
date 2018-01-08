module JsonapiCrud
  module SharedParams

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

    #formats the params into the json:api spec
    def formatted_params(attributes, id = nil, meta = nil)
      data = {}
      data[:type] = model_type
      data[:id] = id if id.present?
      data[:attributes] = attributes if attributes.present?

      p = {}
      p[:data] = data
      p[:meta] = meta if meta.present?

      p
    end

    def delete_params(id, hard = false)
      formatted_params(nil, id, {:hard_delete => hard})
    end

    # this is an empty object that will be used to
    # make sure not including a `data` object will fail.
    # It is defined as a method so mixins can overwrite it
    def missing_data_params
      { }
    end

    def expected_soft_delete_attributes
      [{:json_obj => "json_attributes", :key => "deleted-at", :type_check => "not nil",}]
    end

    # ABSTRACT METHODS
    #
    # def model
    #   nil
    # end
    # def factory
    #   ""
    # end
    #
    # def expected_create_attributes
    #   []
    # end
    #
    # def expected_update_attributes
    #   []
    # end
    #
    # def expected_show_attributes
    #   []
    # end
    #
    # def missing_data_params
    #   {}
    # end
    #
    # def unprocessable_parms(id = nil)
    #   []
    # end

  end
end