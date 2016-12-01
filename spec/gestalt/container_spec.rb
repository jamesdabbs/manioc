require "spec_helper"

RSpec.describe Gestalt::Container do
  let(:container) {
    Gestalt::Container.new do |c|
      c.register(:error) { raise "Nope" }
      c.register(:count) { rand 1 .. 1_000 }
      c.register(:now)   { Time.now }
    end
  }

  it "constructs lazily" do
    expect do
      container.resolve(:error)
    end.to raise_error RuntimeError, "Nope"
  end

  it "caches values" do
    expect(container.resolve :count).to eq container.resolve :count
  end

  it "can reset individual values" do
    old = container.resolve :now
    container.reset :now
    expect(old).not_to eq container.resolve :now
  end

  it "can reset all values" do
    old = container.resolve :now
    container.reset
    expect(old).not_to eq container.resolve :now
  end
end
