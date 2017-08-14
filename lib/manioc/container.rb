require_relative './env'

module Manioc
  class Container
    class DSL < BasicObject
      def initialize &block
        @fields = {}
        instance_exec(&block)
      end

      def to_h
        @fields
      end

      def method_missing name, *args, &block
        return super if args.any?
        @fields[name] = block
      end
    end

    def initialize constructors: {}, &block
      @constructors, @cache = constructors, {}

      @constructors[:env] ||= Manioc::Env.method(:new)

      register(&block) if block
      finalize
    end

    def with &block
      self.class.new constructors: @constructors.dup, &block
    end

    def clone
      with
    end

    def reset! *keys
      keys = @cache.keys if keys.empty?
      keys.each { |k| @cache.delete k }
    end

    def preload!
      @constructors.keys.each { |key| resolve key }
    end

    def inspect
      # :nocov:
      %|<#{self.class.name}(#{@constructors.keys.join(', ')})>|
      # :nocov:
    end

    private

    def register &block
      @constructors.merge! DSL.new(&block).to_h
    end

    def resolve key
      @cache[key] ||= instance_exec(&@constructors[key])
    end

    def finalize
      @constructors.freeze
      @constructors.keys.each do |key|
        define_singleton_method(key) { resolve key }
      end
    end
  end
end
