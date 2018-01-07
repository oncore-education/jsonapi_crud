module JsonapiCrud
  class ControllerGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

    source_root File.expand_path("../../templates", __FILE__)

    class_option :params, :type => :array, :default => []

    #class_option :scope, type: :string, default: 'read_products'


    desc "Creates Controller"

    def create_controller
      output = File.join(JsonapiCrud.configuration.controller_output, "#{controller_file_name}_controller.rb")

      @config = {:base_class => JsonapiCrud.configuration.base_class,
                 :controller_class_name => controller_class_name,
                 :modules => JsonapiCrud.configuration.controller_modules,
                 :params => options[:params]}

      template "controller.rb.erb", output

      puts "Controller created at #{output}"
    end

  end
end