module JsonapiCrud
  module ParamsHelper
    def p_data(source = nil)
      source ||= params
      source.require(:data)
    end

    def p_attributes
      p_data[:attributes]
    end

    def p_relationships
      p_data[:relationships]
    end

    def p_meta
      params[:meta]
    end

    def p_include
      params[:include]
    end
  end
end