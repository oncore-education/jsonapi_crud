module JsonapiCrud
  module ResponseHelper
    def has_http_status(status)
      expect(response).to have_http_status(status)
    end

    def has_error(code, title)
      c = first_error["code"]
      expect(c).to eq(code)

      t = first_error["title"]
      expect(t).to eq(title)
    end

    def unprocessable_entity
      has_http_status(:unprocessable_entity)
      has_error(::JsonapiCrud::ErrorCode::INVALID_ATTRIBUTE, ::JsonapiCrud::ErrorMessage::INVALID_ATTRIBUTE)
    end

    def bad_request
      has_http_status(:bad_request)
      has_error(::JsonapiCrud::ErrorCode::BAD_REQUEST, ::JsonapiCrud::ErrorMessage::BAD_REQUEST)
    end

    def not_authorized
      has_http_status(:unauthorized)
      has_error(::JsonapiCrud::ErrorCode::NOT_AUTHORIZED, ::JsonapiCrud::ErrorMessage::NOT_AUTHORIZED)
    end

    def invalid_api_token
      has_http_status(:unauthorized)
      has_error(::JsonapiCrud::ErrorCode::INVALID_API_TOKEN, ::JsonapiCrud::ErrorMessage::INVALID_API_TOKEN)
    end

    def record_not_found
      has_http_status(:not_found)
      has_error(::JsonapiCrud::ErrorCode::NOT_FOUND, ::JsonapiCrud::ErrorMessage::NOT_FOUND)
    end

    def parse_key(key)
      return Integer(key)
    rescue
      key
    end

    def verify_response_body(expectations)
      expectations.each do |p|
        json_obj = send( p[:json_obj] )
        key = p[:key]
        value = json_obj[key]
        filter = p[:filter]
        filter = "json_data(value)['id']" if filter.nil? && p[:json_obj] == "json_relationships"
        if filter.present?
          # a = filter.split(".")
          # a.each do |k|
          #   value = value[ parse_key(k)]
          # end
          value = eval(filter)
        end
        expected_value = parse_expected_value(p)
        expected_value
        if p[:type_check].nil?
          expect( value ).to eq( expected_value )
        elsif p[:type_check] == "not nil"
          expect( value ).to_not be_nil
        elsif p[:type_check] == "nil"
          expect( value ).to be_nil
        end
      end
    end

    def parse_expected_value(p)
      value = p[:value]
      return eval(value) if p[:eval]

      value

      # if expected_value.to_s.start_with? ""
      #   return eval(expected_value)
      #
      #   a = expected_value.split(".")
      #   obj = a[1]
      #   method = a[2]
      #   value = send(obj)[method]
      #   if a[3].present?
      #     value = value.send(a[3])
      #   end
      #   return value
      #
      # end
      #
      # expected_value
    end
  end
end