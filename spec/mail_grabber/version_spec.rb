# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'MailGrabber::VERSION' do
  it 'has a version number' do
    expect(MailGrabber::VERSION).not_to be_nil
  end
end
