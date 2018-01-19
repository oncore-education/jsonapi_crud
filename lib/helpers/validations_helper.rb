module JsonapiCrud

  module ValidationsHelper
    def is_uuid?(uuid)
      format = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
      format.match?(uuid.to_s.downcase)
    end
  end

end