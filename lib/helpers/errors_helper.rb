module JsonapiCrud

  module ErrorCode
    NOT_AUTHORIZED = 1000
    NOT_FOUND = 1001
    INVALID_API_TOKEN = 1002
    INVALID_ATTRIBUTE = 1003
    BAD_REQUEST = 1004
  end

  module ErrorMessage
    NOT_AUTHORIZED = 'Not Authorized'
    NOT_FOUND = 'Record Not Found'
    INVALID_API_TOKEN = 'Invalid API Token'
    INVALID_ATTRIBUTE = 'Invalid Attribute'
    BAD_REQUEST = 'Bad Request'
  end

  module ErrorsHelper
    def render_errors
      if Errors.has_errors?
        render :json => Errors.output, status: ::OCE::Errors.status
      end
    end

    def render_error(error)
      render :json => {errors: [error]}, status: error.status
    end
  end

end