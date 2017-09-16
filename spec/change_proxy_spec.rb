require 'spec_helper'
require 'change_proxy'

RSpec.describe ChangeProxy do
  it 'has a version number' do
    expect(ChangeProxy::VERSION).not_to be nil
  end
end
