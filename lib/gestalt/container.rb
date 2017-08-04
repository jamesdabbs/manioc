module Gestalt
  class Container
    class DSL
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

    def initialize **constructors, &block
      @constructors, @instances = constructors, {}

      register(&block) if block
      finalize
    end

    def with &block
      self.class.new @constructors.dup, &block
    end

    def reset key=nil
      keys = key ? [key] : @instances.keys
      keys.each { |k| @instances.delete k }
    end

    private

    def register &block
      @constructors.merge! DSL.new(&block).to_h
    end

    def resolve key
      @instances[key] ||= instance_exec(&@constructors[key])
    end

    def finalize
      @constructors.freeze
      @constructors.each do |key,_|
        define_singleton_method(key) { resolve key }
      end
    end
  end
end
