module JsonapiCrud
  module SerializerHelper

    def self.included(base)
      class << base

        def serializer_type
          "#{self.name.underscore}_serializer".classify.constantize
        end

        def serializer
          obj =  self.name.constantize.new
          self.serializer_type.new(obj)
        end

        def serialized_attributes
          self.serializer.attributes.keys
        end

        def valid_attributes
          private_attributes = []
          if serializer_type.method_defined? :private_attributes
            private_attributes = serializer.private_attributes.map { |attr| attr.split(":").first.to_sym }
          end

          self.serialized_attributes.reject { |key| key.to_s == "id" } + private_attributes
        end

        def serialized_relationships
          self.serializer.associations.map{ |assoc| assoc.name }
        end
      end
    end

    def serialized_relationships
      self.class.name.constantize.serialized_relationships
    end

  end
end