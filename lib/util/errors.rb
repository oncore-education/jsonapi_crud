module JsonapiCrud
  class Errors

    @errors = []

    def initialize
      @errors = []
    end

    def self.add(error)
      @errors.push(error)
    end

    def self.has_errors?
      @errors.count > 0
    end

    def self.status
      s = nil

      @errors.each do |e|
        if s.nil?
          s = e.status
          next
        end

        if e.status != s
          return :bad_request
        end
      end

      s
    end

    def self.output
      {:errors => @errors}
    end

  end
end
