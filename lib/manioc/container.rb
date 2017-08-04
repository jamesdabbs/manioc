module Manioc
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

    def initialize cache: true, preload: false, constructors: {}, &block
      @constructors = constructors
      @cache        = cache ? {} : nil
      @preload      = preload

      register(&block) if block
      finalize
    end

    def with &block
      self.class.new \
        constructors: @constructors.dup,
        cache:        !@cache.nil?,
        preload:      @preload,
        &block
    end

    def clone
      with
    end

    def reset key=nil
      return unless @cache
      keys = key ? [key] : @cache.keys
      keys.each { |k| @cache.delete k }
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
      instance_exec(&@constructors[key])
    end

    def finalize
      @constructors.freeze
      @constructors.each do |key,_|
        if @cache
          define_singleton_method(key) { @cache[key] ||= resolve key }
        else
          define_singleton_method(key) { resolve key }
        end

        if @preload
          public_send key
        end
      end
    end
  end
end
