require 'colorize'

module JsonapiCrud
  #module Generators
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../../templates", __FILE__)
    desc "Creates JsonapiCrud initializer for your application"

    def copy_initializer
      template "jsonapi_crud_initializer.rb", "config/initializers/jsonapi_crud.rb"
    end

    def copy_rspec
      output = "spec/support"
      source_content = File.expand_path("../../templates/support/jsonapi_crud", __FILE__)
      FileUtils.cp_r source_content, output

      Dir["#{source_content}/**/*.rb"].each do |f|
        #puts f
        dest = f.split("support/jsonapi_crud")[1]
        puts "#{"     create".yellow} #{output}#{dest}"
      end
    end
  end
  #end
end