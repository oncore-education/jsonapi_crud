module JsonapiCrud
  class SpecGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

    source_root File.expand_path("../../templates", __FILE__)

    class_option :template, :type => :string, :default => nil
    class_option :output, :type => :string, :default => ""

    #class_option :scope, type: :string, default: 'read_products'

    desc "Creates Spec"

    def create_request_spec
      @config = basic_config

      output = File.join("spec/requests/#{options[:output]}", "#{@config[:type]}_requests_spec.rb")

      overrides = ["request_spec.rb.erb"]
      overrides.unshift options[:template] if options[:template].present?

      template_override = nil
      overrides.each do |f|
        t = Rails.root.join("spec/support/jsonapi_crud/templates/#{f}")
        if File.exist?(t)
          puts t
          template_override = t
          break
        end

      end

      if template_override.present?
        template File.expand_path("#{template_override}", __FILE__), output
      else
        template "request_spec.rb.erb", output
      end

    end

    private

    def basic_config
      type = controller_class_name.underscore.downcase
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