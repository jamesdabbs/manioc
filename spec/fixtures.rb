module Fixtures
  class HTTP < Gestalt[]
    def call; "http" end
  end

  class Numberizer < Gestalt[:number, :http]
    def call other; "#{http.call} #{number} #{other}" end
  end

  class Stringulator < Gestalt[:string]
    def call; "stringulator: #{string}" end
  end

  class Integrator < Gestalt[:stringulator, :numberizer]
    def call; numberizer.call stringulator.call end
  end
end
