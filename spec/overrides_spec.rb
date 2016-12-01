require "spec_helper"

class Flooper < Gestalt[:str, :num, :env]
  defaults env: "dev"
end

RSpec.describe "overriding dependencies" do
  let(:c) do
    Gestalt::Container.new do |c|
      c.register(:str)    { "hello" }
      c.register(:number) { 2 }

      c.register(:flooper) { build Flooper, num: :number }
    end
  end

  it "can resolve" do
    f = c.construct :flooper
    expect(f.num).to eq 2
    expect(f.str).to eq "hello"
    expect(f.env).to eq "dev"
  end

  it "can override injected dependencies" do
    f = c.construct :flooper, str: "overridden"
    expect(f.num).to eq 2
    expect(f.str).to eq "overridden"
  end

  it "can override values from the key map" do
    f = c.construct :flooper, num: 15
    expect(f.num).to eq 15
    expect(f.str).to eq "hello"
  end

  context "with defaults overridden in container" do
    let(:d) {
      c.with do |d|
        d.register(:env) { "test" }
      end
    }

    it "uses container values" do
      f = d.construct :flooper
      expect(f.env).to eq "test"
    end

    it "can override provided values" do
      f = d.construct :flooper, env: "prod"
      expect(f.env).to eq "prod"
    end
  end
end
