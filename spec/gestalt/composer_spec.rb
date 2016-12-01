require "spec_helper"

class ComposerTest
  include Gestalt::Composer[Either]

  def initialize other
    @other = other
  end

  # a -> [a, a]
  def pair val
    [val, @other].flatten.compact
  end

  # [a,a] -> E[a]
  def times array
    if array.length == 2
      success(array[0] * array[1])
    else
      error("times expects an array with two values")
    end
  end

  # a -> String
  def stringify val
    val.to_s
  end

  # String -> E[String]
  def palindrome str
    if str == str.reverse
      success str
    else
      error "#{str} is not a palindrome"
    end
  end

  def explicit val
    compose(
      lift(:pair),
      bind(:times),
      lift(:stringify),
      bind(:palindrome)
    ).call val
  end

  def implicit val
    compose do
      lift :pair
      bind :times
      lift :stringify
      bind :palindrome
    end.call val
  end

  def dynamic val, step, final
    compose(
      lift(:pair),
      bind(:times),
      step,
      lift(final)
    ).call val
  end
end

RSpec.describe Gestalt::Composer,
    covers: [Gestalt::Composer, Gestalt::Composer::Proxy] do
  let(:comp) { ComposerTest.new 11 }

  context "explicit" do
    it "can chain" do
      expect(comp.explicit(11).value).to eq "121"
    end
    it "can error" do
      expect(comp.explicit(12).error).to eq "132 is not a palindrome"
    end
    it "can propagate errors" do
      expect(comp.explicit(nil).error).to eq "times expects an array with two values"
    end
  end

  context "implicit" do
    it "can chain" do
      expect(comp.implicit(11).value).to eq "121"
    end
    it "can error" do
      expect(comp.implicit(12).error).to eq "132 is not a palindrome"
    end
    it "can propagate errors" do
      expect(comp.implicit(nil).error).to eq "times expects an array with two values"
    end
  end

  context "dynamic" do
    it "can inject a step" do
      const = ->(_) { Either.success :polarity }
      fin   = ->(s) { s.to_s.reverse.to_sym }
      expect(comp.dynamic(5, const, fin).value).to eq :ytiralop
    end

    it "can inject a failure" do
      const = ->(_) { Either.error "mistakes were made" }
      fin   = :reverse.to_proc
      expect(comp.dynamic(5, const, fin).error).to eq "mistakes were made"
    end
  end
end
