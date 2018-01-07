module JsonapiCrud
  class Error
    attr_accessor :status,
                  :code,
                  :pointer,
                  :title,
                  :detail

    def initialize(options = {})
      self.status = options[:status]
      self.code = options[:code]
      self.pointer = options[:pointer]
      self.title = options[:title]
      self.pointer = options[:pointer]
      self.detail = options[:detail]
    end

    def output
      params = {}
      params.merge!(:status => status) unless status.nil?
      params.merge!(:code => code) unless code.nil?
      params.merge!(:source => {:pointer => pointer}) unless pointer.nil?
      params.merge!(:title => title) unless title.nil?
      params.merge!(:detail => detail) unless detail.nil?
    end

    def self.not_found(detail = "")
      Error.new(code: ErrorCode::NOT_FOUND,
                title: ErrorMessage::NOT_FOUND,
                detail: detail,
                status: :not_found)
    end

    def self.bad_request(detail = "")
      Error.new(code: ErrorCode::BAD_REQUEST,
                title: ErrorMessage::BAD_REQUEST,
                detail: detail,
                status: :bad_request)
    end

    def self.not_authorized(detail = "")
      Error.new(code: ErrorCode::NOT_AUTHORIZED,
                title: ErrorMessage::NOT_AUTHORIZED,
                detail: detail,
                status: :unauthorized)
    end

    def self.expired_subscription(detail = "")
      Error.new(code: ErrorCode::EXPIRED_SUBSCRIPTION,
                title: ErrorMessage::EXPIRED_SUBSCRIPTION,
                detail: detail,
                status: :unauthorized)
    end

    def self.invalid_api_key(detail = "")
      Error.new(code: ErrorCode::INVALID_API_TOKEN,
                title: ErrorMessage::INVALID_API_TOKEN,
                detail: detail,
                status: :unauthorized)
    end

    def self.invalid_attribute(pointer, detail = "")
      Error.new(code: ErrorCode::INVALID_ATTRIBUTE,
                title: ErrorMessage::INVALID_ATTRIBUTE,
                detail: detail,
                pointer: pointer,
                status: :unprocessable_entity)
    end
  end
end