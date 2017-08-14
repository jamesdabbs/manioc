require 'spec_helper'

use 'container'

RSpec.describe Manioc::Container do
  let(:config) { proc {
    error  { raise 'nope'}
    count  { rand 1 .. 1_000 }
    now    { Time.now }
    a      { 1 }
    b      { a * 2 }
    c      { b * 3 }
  } }

  let(:container) {
    Manioc::Container.new(&config)
  }

  it 'constructs lazily' do
    expect { container.error }.to raise_error 'nope'
  end

  it 'caches values' do
    expect(container.count).to eq container.count
  end

  it 'can reset individual values' do
    old = container.now
    container.reset! :now
    expect(container.now).to be > old
  end

  it 'can reset all values' do
    old = container.now
    container.reset!
    expect(container.now).to be > old
  end

  it 'can override values' do
    overridden = container.with do
      b { a * 10}
    end

    expect(container.c ).to eq 6
    expect(overridden.c).to eq 30

    expect(container.b ).to eq 2
    expect(overridden.b).to eq 10
  end

  it 'can preload' do
    expect { Manioc::Container.new(&config).preload! }.to raise_error 'nope'
  end

  it 'can clone' do
    clone = container.clone
    first  = clone.now
    second = container.now
    expect(second).to be > first
  end

  context 'environment variables' do
    let(:container) {
      Manioc::Container.new do
        a { env.A }
        b { env.B! }
      end
    }

    around :each do |ex|
      ENV['A'] = 'a'
      ex.call
      ENV['A'] = nil
    end

    it 'can read environment variables' do
      expect(container.a).to eq 'a'
    end

    it 'errors if required variables are unset' do
      expect { container.b }.to raise_error(Manioc::Env::Unset, 'B')
    end
  end
end
