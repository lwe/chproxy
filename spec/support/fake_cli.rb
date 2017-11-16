# frozen_string_literal: true

class FakeCli
  attr_reader :messages
  def initialize
    @messages = []
  end

  def say(message)
    messages << message.to_s
  end

  def say_status(status, message, color = nil)
    prefix = color ? "*#{color}* " : ''
    messages << "#{prefix}[#{status}]: #{message}"
  end
end
