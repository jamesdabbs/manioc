module Gestalt::Composer
  def self.[] monad
    @_modules ||= {}
    @_modules[monad] ||= Module.new do
      include monad::Constructors

      define_method :lift do |f|
        monad.lift _proc(f)
      end

      define_method :bind do |f|
        monad.bind _proc(f)
      end

      def compose *procs, &block
        Gestalt::Composer::Proxy.new(self, procs, &block)
      end

      def _proc f
        if f.respond_to? :call
          f
        else
          method(f).to_proc
        end
      end
    end
  end

  class Proxy
    def initialize context, pipeline, &config
      @context, @pipeline = context, pipeline
      instance_exec(&config) if config
      freeze
    end

    def call val
      pipeline.reduce(context.pure val) do |acc, func|
        func.call acc
      end
    end

    private

    attr_reader :context, :pipeline

    def bind name
      pipeline.push context.bind name
    end

    def lift name
      pipeline.push context.lift name
    end
  end
end
