JsonapiCrud.configure do |config|
  config.controller_output = Rails.root + "/app/controllers"
  config.controller_modules = []
  config.base_class = "ApplicationRecord"
end