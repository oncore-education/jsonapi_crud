module JsonapiCrud
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

    def json_data
      json["data"]
    end

    def json_meta
      json["meta"]
    end

    def json_attributes
      json_data["attributes"]
    end
  end
end