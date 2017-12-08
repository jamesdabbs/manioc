module Manioc
  class Env
    Unset = Class.new StandardError

    def fetch key
      ENV[key] || raise(Unest, key)
    end

    def [] key
      ENV[key]
    end

    def method_missing name, *args
      super if args.count > 1
      if name =~ /\A(.*)!\Z/
        fetch $1
      else
        self[name.to_s]
      end
    end
  end
end
