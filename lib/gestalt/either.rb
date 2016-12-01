module Either
  Value = Struct.new :value, :error

  module Constructors
    def success val
      Either::Value.new val, nil
    end
    def error val
      Either::Value.new nil, val
    end
    def pure val
      success val
    end
  end

  extend Constructors

  def self.bind f
    ->(ev) { ev.error ? ev : f.call(ev.value) }
  end
  def self.lift f
    ->(ev) { ev.error ? ev : success(f.call ev.value) }
  end
end
