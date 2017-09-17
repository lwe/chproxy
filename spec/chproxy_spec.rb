# frozen_string_literal: true

require 'spec_helper'
require 'chproxy'

RSpec.describe Chproxy do
  it 'has a version number' do
    expect(Chproxy::VERSION).not_to be nil
  end

  pending 'Chproxy::CLI'
end
