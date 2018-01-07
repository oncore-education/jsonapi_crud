module JsonapiCrud
  class ResponseObject
    attr_accessor :obj,
                  :status,
                  :meta,
                  :include

    def initialize(options = {})
      self.obj = options[:obj]
      self.status = options[:status] || :ok
      self.meta = options[:meta]
      self.include = options[:include]
    end

    def options
      opts = {}
      opts[:status] = status
      opts[:meta] = meta if meta.present?
      opts[:include] = include if include.present?

      opts
    end
  end
end