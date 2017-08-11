module Manioc
  class Rails::Application
    def self.container &setup
      if setup
        config.container = config.container.with(&setup)
      else
        config.container
      end
    end

    def container &setup
      self.class.container(&setup)
    end
  end

  class Railtie < ::Rails::Railtie
    _app = nil
    config.before_configuration do |app|
      _app = app
      _app.config.container = Manioc::Container.new
    end

    reset = ->{ _app.config.container.reset! }

    config.to_prepare do
      if _app.config.eager_load
        _app.config.container.preload!
      else
        reset.call
      end
    end

    if ActiveSupport.const_defined?(:Reloader) && ActiveSupport::Reloader.respond_to?(:to_complete)
      ActiveSupport::Reloader.to_complete do
        reset.call
      end
    elsif ActionDispatch.const_defined?(:Reloader) && ActionDispatch::Reloader.respond_to?(:to_cleanup)
      ActionDispatch::Reloader.to_cleanup do
        reset.call
      end
    end
  end
end
