module JsonapiCrud
  module HttpHelper

    def make_req( user, url, method = :get, params = {} )
      if user.nil?
        auth_req(method, url, params)
      else
        user_req(user, method, url, params)
      end
    end

    def api_req ( method, url, params = {}, headers = {} )
      req( method, url, params, headers)
    end

    def auth_req ( method, url, params = {}, headers = {}  )
      user = create(:user)

      user_req( user, method, url, params, headers)
    end

    def user_req ( user, method, url, params = {}, headers = {}  )
      user ||= create(:user)
      token = JsonWebToken.encode(user_id: user.id)
      headers.merge!( "Authorization" => " #{token}" )

      api_req( method, url, params, headers)
    end

    def req ( method, url, params, headers = {} )
      case method
        when :post
          post_req( url, params, headers )
        when :put
          put_req( url, params, headers )
        when :patch
          patch_req( url, params, headers )
        when :delete
          delete_req( url, params, headers )
        else
          get_req( url, params, headers )
      end
    end

    def delete_req ( url, params = {}, headers = {} )
      delete url, :params => params, :headers => headers
    end

    def patch_req ( url, params = {}, headers = {} )
      patch url, :params => params, :headers => headers
    end

    def put_req ( url, params = {}, headers = {} )
      put url, :params => params, :headers => headers
    end

    def post_req ( url, params = {}, headers = {} )
      post url, :params => params, :headers => headers
    end

    def get_req ( url, params= {}, headers = {} )
      get url, :params => params, :headers => headers
    end

  end
end