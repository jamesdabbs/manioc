module Gestalt
  class Builder
    def initialize klass, map={}
      @klass, @map = klass, map
    end

    def call container, overrides
      overridden = container.with do |c|
        overrides.each do |key,val|
          c.register(translate key) { val }
        end
      end
      fields = klass.dependencies.each_with_object({}) do |key, hash|
        hash[key] = resolve key, overridden
      end
      klass.new fields
    end

    private

    attr_reader :klass, :map

    def resolve key, container
      container[translate key] || klass.defaults[key]
    end

    def translate key
      map[key] || key
    end
  end
end
