require "concurrent"

require "gestalt/builder"
require "gestalt/container"
require "gestalt/composer"
require "gestalt/either"
require "gestalt/extensions"
require "gestalt/struct"
require "gestalt/version"

module Gestalt
  def self.[] *dependencies
    Class.new Struct do
      # This allows us to close over `dependencies`
      define_singleton_method :dependencies do
        dependencies
      end

      dependencies.each { |dep| attr_reader dep }
    end
  end
end
