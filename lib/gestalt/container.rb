module Gestalt
  class Container
    NotRegistered = Class.new StandardError

    def initialize
      @constructors, @instances = Concurrent::Hash.new, Concurrent::Hash.new
      yield self if block_given?
      @constructors.freeze
    end

    def register key, &block
      constructors[key] = block
    end

    def build klass, key_map={}
      Builder.new klass, key_map
    end

    def construct key, **overrides
      cons = constructors[key]
      return unless cons
      res = instance_exec(&cons)
      if res.is_a? Builder
        res.call self, overrides
      elsif res.is_a?(Class) && res < Gestalt::Struct
        Builder.new(res).call self, overrides
      else
        res
      end
    end

    def [] key
      instances[key] ||= construct(key)
    end

    def resolve key
      self[key] || raise(NotRegistered, "`#{key}` not registered")
    end

    def reset *keys
      if keys.any?
        keys.each { |key| instances.delete key }
      else
        instances.clear
      end
    end

    def with &overrides
      self.class.new do |c|
        constructors.each { |key, cons| c.register(key, &cons) }
        # TODO: it's too easy to accidentally "override" using the wrong name, in which case
        #   the old value still gets used silently
        overrides.call c
      end
    end

    private

    attr_reader :constructors, :instances
  end
end
