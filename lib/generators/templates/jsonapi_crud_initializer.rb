require 'jsonapi_crud'

JsonapiCrud.configure do |config|
  config.controller_output = Rails.root + "/app/controllers"
  config.controller_modules = []
  config.base_url = "/v1"
  config.base_class = "ApplicationRecord"
end