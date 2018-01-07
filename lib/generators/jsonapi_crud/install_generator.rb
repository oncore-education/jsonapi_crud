module JsonapiCrud
  #module Generators
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../../templates", __FILE__)
    desc "Creates JsonapiCrud initializer for your application"

    def copy_initializer
      template "jsonapi_crud_initializer.rb", "config/initializers/jsonapi_crud.rb"

      puts "All your json crud are belong to us"
    end
  end
  #end
end