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

    config.to_prepare do
      if _app.config.eager_load
        _app.config.container.preload!
      else
        _app.config.container.reset!
      end
    end
  end
end
