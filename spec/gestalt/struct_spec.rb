require "spec_helper"

RSpec.describe Gestalt::Struct do
  def pipe *fs
    ->(val) { fs.reduce(val) { |acc,f| f.call acc } }
  end

  it "verifies fields are present" do
    expect { Fixtures::Stringulator.new }.to raise_error KeyError, /string/
  end

  it "verifies fields are defined" do
    expect { Fixtures::Stringulator.new string: "foo", extra: 5 }.to \
      raise_error KeyError, /extra/
  end

  let(:n) { Fixtures::Numberizer.new http: ->{ "_" }, number: 1 }

  it "is composable with other structs" do
    chain = pipe n, n, n
    expect(chain.call "test").to eq "_ 1 _ 1 _ 1 test"
  end

  it "is composable with procs" do
    chain = pipe n, ->(x) { x.reverse }
    expect(chain.call "asdf racecar").to eq "racecar fdsa 1 _"
  end

  it "can check for equality" do
    h = ->{ }
    n = rand  1 .. 10
    m = rand 11 .. 20

    expect(Fixtures::Numberizer.new http: h, number: n).to     eq Fixtures::Numberizer.new http: h, number: n
    expect(Fixtures::Numberizer.new http: h, number: n).not_to eq Fixtures::Numberizer.new http: h, number: m
  end
end
