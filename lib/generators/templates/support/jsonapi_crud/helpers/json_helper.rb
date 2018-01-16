module JsonapiCrud

  module JsonResponse
    ATTRIBUTES ||= 'json_attributes'
    META ||= 'json_meta'
    DATA ||= 'json_data'
    RELATIONSHIPS ||= 'json_relationships'
  end

  module JsonHelper
    def json
      JSON.parse(response.body)
    end

    def errors
      json["errors"]
    end

    def first_error
      json["errors"].first
    end

    def json_data(source = nil)
      source ||= json
      source["data"]
    end

    def json_meta
      json["meta"]
    end

    def json_attributes
      json_data()["attributes"]
    end

    def json_relationships
      json_data()["relationships"]
    end
  end
end