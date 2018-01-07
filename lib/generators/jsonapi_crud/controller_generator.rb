module JsonapiCrud
  class ControllerGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

    source_root File.expand_path("../../templates", __FILE__)

    class_option :params, :type => :array, :default => []

    #class_option :scope, type: :string, default: 'read_products'


    desc "Creates Controller"

    def create_controller
      output = File.join(JsonapiCrud.configuration.controller_output, "#{controller_file_name}_controller.rb")



      erb_template("controller.rb.erb",
                   output,
                   {:base_class => JsonapiCrud.configuration.base_class,
                           :controller_class_name => controller_class_name,
                           :modules => JsonapiCrud.configuration.controller_modules,
                           :params => options[:params]})

      puts "Controller created at #{output}"
    end

    private

    def erb_template(source, destination, config)
      if File.exist?(destination) && !options[:force]
        raise Exception.new('A file already exists at that location, use force: true to overwrite it')
      end
      source_content = File.read( File.expand_path("../../templates/#{source}", __FILE__) )
      template = ERB.new(source_content).result(binding)

      if destination.index('/')
        path = destination[0..(destination.rindex('/')-1)]
        Dir.mkdir(path) unless Dir.exist?(path) || path == ".."
      end
      File.write(destination, template)
    end

  end
end