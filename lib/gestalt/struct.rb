module Gestalt
  class Struct
    def self.defaults values=nil
      values ? @defaults=values : @defaults
    end

    def initialize **fields
      _validate fields
      _assign   fields
      freeze
    end

    def == other
      super || self.class.dependencies.all? { |dep| public_send(dep) == other.public_send(dep) }
    end

    private

    def _validate fields
      missing = self.class.dependencies - fields.keys
      if missing.any?
        raise KeyError, "#{self}(#{self.class}) missing fields #{missing}"
      end

      extra = fields.keys - self.class.dependencies
      if extra.any?
        raise KeyError, "#{self}(#{self.class}) passed extra fields #{extra}"
      end
    end

    def _assign fields
      fields.each { |k,v| instance_variable_set :"@#{k}", v }
    end
  end
end
