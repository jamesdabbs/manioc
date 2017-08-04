module Manioc
  class << self
    def [] *fields, **defaults
      fields = (fields + defaults.keys).uniq

      Class.new Struct do
        define_singleton_method(:fields  ) { fields }
        define_singleton_method(:defaults) { defaults }

        fields.each do |field|
          attr_reader field
        end
      end
    end

    def frozen= val
      @frozen = val
    end
    def frozen?
      @frozen
    end
  end
  self.frozen = true

  class Struct
    def initialize **fields
      fields = self.class.defaults.merge fields
      _validate fields
      _assign   fields
      freeze if Manioc.frozen?
    end

    def == other
      super || to_h == other.to_h
    end

    def with **fields
      self.class.new to_h.merge fields
    end

    def to_h
      self.class.fields.each_with_object({}) { |field,h| h[field] = public_send field }
    end

    private

    def _validate fields
      missing = self.class.fields - fields.keys
      if missing.any?
        raise KeyError, "#{self}(#{self.class}) missing fields #{missing}"
      end

      extra = fields.keys - self.class.fields
      if extra.any?
        raise KeyError, "#{self}(#{self.class}) passed extra fields #{extra}"
      end
    end

    def _assign fields
      fields.each { |k,v| instance_variable_set :"@#{k}", v }
    end
  end
end
