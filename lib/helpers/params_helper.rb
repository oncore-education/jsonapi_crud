module JsonapiCrud
  module ParamsHelper
    def p_data(source = nil)
      source ||= params
      return source[:data] if request.method == 'DELETE'
      source.require(:data)
    end

    def p_attributes
      p_data[:attributes] || ActionController::Parameters.new
    end

    def p_relationships
      p_data[:relationships]
    end

    def p_relatonship(r)
      p_data[p_relationships[r]]
    end

    def p_included(type, id = nil)
      return params[:included]
                 .select{ |item|
                   item[:type] == type && (id.present? && item[:id] == id )
                 } if params[:included].present?
      []
    end

    def p_meta(source = nil)
      p_data(source)[:meta]
      #params[:meta]
    end

    def p_resource_meta
      params[:_meta]
    end

    def p_include
      params[:include]
    end
  end
end