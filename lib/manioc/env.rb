module Manioc
  class Env
    Unset = Class.new StandardError

    def method_missing name, *args
      super if args.count > 1
      if name =~ /\A(.*)!\Z/
        ENV[$1] || raise(Unset, $1)
      else
        ENV[name.to_s]
      end
    end
  end
end
