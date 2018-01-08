require 'jsonapi_crud/version'
require 'mixins/actions'
require 'util/errors'
require 'models/error'
require 'models/response_object'

class String
  def jsonapi_underscore
    self.underscore.gsub('-', '_')
  end
end

module JsonapiCrud
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :controller_output,
                  :controller_modules,
                  :base_class,
                  :base_url

    def initialize
      @controller_output = Rails.root + "/app/controllers"
      @controller_modules = []
      @base_class = "ApplicationRecord"
      @base_url = ""
    end
  end
end
