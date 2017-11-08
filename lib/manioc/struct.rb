module Manioc
  class << self
    def [] *fields, **defaults
      Struct.configure \
        fields:   fields,
        defaults: defaults,
        mutable:  false
    end

    def mutable *fields, **defaults
      Struct.configure \
        fields:   fields,
        defaults: defaults,
        mutable:  true
    end

    attr_accessor :frozen

    def frozen?; frozen; end
  end

  self.frozen = true

  class Struct
    class Config
      attr_accessor :fields, :defaults, :mutable

      def mutable?;     mutable end
      def immutable?; !mutable? end
    end

    def self.configure fields: [], defaults: {}, mutable: Manioc.frozen?
      config = Config.new.tap do |c|
        c.fields   = fields + defaults.keys
        c.defaults = defaults
        c.mutable  = mutable
      end

      Class.new Struct do
        define_singleton_method(:config) { config }

        config.fields.each do |field|
          if config.mutable
            attr_accessor field
          else
            attr_reader field
          end
        end
      end
    end

    def initialize **fields
      fields = self.class.config.defaults.merge fields
      _validate fields
      _assign   fields
      freeze if Manioc.frozen? && self.class.config.immutable?
    end

    def == other
      super || to_h == other.to_h
    end

    def with **fields
      self.class.new to_h.merge fields
    end

    def to_h
      self.class.config.fields.each_with_object({}) { |field,h| h[field] = public_send field }
    end

    def inspect
      # :nocov:
      %|<#{self.class.name}(#{self.class.fields.join(', ')})>|
      # :nocov:
    end

    private

    def _validate fields
      missing = self.class.config.fields - fields.keys
      if missing.any?
        raise KeyError, "#{self}(#{self.class}) missing fields #{missing}"
      end

      extra = fields.keys - self.class.config.fields
      if extra.any?
        raise KeyError, "#{self}(#{self.class}) passed extra fields #{extra}"
      end
    end

    def _assign fields
      fields.each { |k,v| instance_variable_set :"@#{k}", v }
    end
  end
end
