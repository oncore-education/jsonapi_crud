module JsonapiCrud
  module Policy

    attr_accessor :model, :user, :obj, :params

    def index
      @model.all
    end

    def can_create?
      true
    end

    def can_show?
      true
    end

    def can_edit?
      true
    end

    def can_destory?
      true
    end

    def can_restore?
      true
    end

    def permitted_attributes
      nil
    end

    def permitted_relationships
      nil
    end

    def mine

    end

    def method_missing(method, *args, &block)
      puts "Policy.method_missing #{method}"
      return true
    end

    def initialize(model)
      @model = model
    end

    def authorized?(params = {}, obj = nil)
      self.obj = obj
      self.params = params

      action =  params[:action]

      puts ">>>>>>>>>>>>>> Policy.authorize  #{action} / #{params} / #{obj}"

      allowable = self.send("can_#{action}?")
      allowable && action.present?
    end

  end
end

