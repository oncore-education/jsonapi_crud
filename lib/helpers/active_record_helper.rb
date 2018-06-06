module JsonapiCrud
  module ActiveRecordHelper

    def editable_relationships
      # self.serialized_relationships.select{ |name| name.to_s.pluralize == name.to_s }
      self.serialized_relationships.map{ |name| name.to_s }
    end

    def can_update_relationship?(key)
      self.send(key).nil? || editable_relationships.include?(key) # .to_sym
    end

    def can_relate?(key)
      return false unless can_update_relationship?(key)
      self.serialized_relationships.include? key.to_sym

      # a = valid_relationships
      # if a.is_a?(Hash)
      #   a = a[params[:action].to_sym] || []
      # end
      # a.include?(key.to_sym)
    end

  end
end


