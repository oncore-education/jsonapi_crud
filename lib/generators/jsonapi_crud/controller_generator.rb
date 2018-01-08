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
    end

    def create_spec_params

      @config = basic_config
      @config[:base_url] = JsonapiCrud.configuration.base_url

      output = File.join("spec/support/jsonapi_crud/params", "#{@config[:model]}_params.rb")

      template "model_params.rb.erb", output
    end

    def create_request_spec
      @config = basic_config

      output = File.join("spec/requests", "#{@config[:type]}_requests_spec.rb")

      template_override = Rails.root.join("spec/support/jsonapi_crud/requests_spec_template.rb.erb")
      if File.exist?(template_override)
        template File.expand_path("#{template_override}", __FILE__), output
      else
        template "request_spec.rb.erb", output
      end

    end

    private

    def basic_config
      type = controller_class_name.downcase
      model = type.singularize
      classname = model.classify

      config = {}
      config[:type] = type
      config[:model] = model
      config[:classname] = classname

      config
    end
  end
end