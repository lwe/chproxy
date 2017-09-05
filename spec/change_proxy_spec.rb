require 'spec_helper'
require 'toml'
require 'pp'
require 'change_proxy/location'

RSpec.describe ChangeProxy do
  it 'has a version number' do
    expect(ChangeProxy::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end

  it 'parses TOML file' do
    cfg = TOML.load_file('spec/fixtures/chproxy.toml')
    cfg['location'].each do |key, options|
      loc = ChangeProxy::Location.new(key, options)
      pp loc
      pp loc.active?
    end
  end
end
