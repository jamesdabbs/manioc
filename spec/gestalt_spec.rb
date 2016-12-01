require 'spec_helper'

RSpec.describe Fixtures do
  it 'records dependencies' do
    expect(Fixtures::HTTP.dependencies).to eq []
    expect(Fixtures::Numberizer.dependencies).to eq [:number, :http]
  end
end

RSpec.describe Gestalt::Container do
  let(:container) do
    Gestalt::Container.new do |c|
      c.register(:number) { 2 }
      c.register(:string) { "two" }

      c.register(:http)         { Fixtures::HTTP }
      c.register(:numberizer)   { Fixtures::Numberizer}
      c.register(:stringulator) { Fixtures::Stringulator }
      c.register(:integrator)   { Fixtures::Integrator }
    end
  end

  context 'no container' do
    it 'can build http directly' do
      http = Fixtures::HTTP.new
      expect(http.call).to eq 'http'
    end
  end

  context 'default container resolution' do
    it 'can build http' do
      http = container.resolve :http
      expect(http.call).to eq 'http'
    end

    it 'can build numberizer' do
      num = container.resolve :numberizer
      expect(num.call 3).to eq "http 2 3"
    end

    it 'can build integrator' do
      integrator = container.resolve :integrator
      expect(integrator.call).to eq "http 2 stringulator: two"
    end
  end

  context 'overriding resolution' do
    it 'can override direct dependencies' do
      num = container.construct :numberizer, number: 5
      expect(num.call 10).to eq "http 5 10"
    end

    it 'can override transient dependencies' do
      int = container.construct :integrator, http: ->{ "floop" }
      expect(int.call).to eq "floop 2 stringulator: two"
    end
  end
end
