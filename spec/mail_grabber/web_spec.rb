# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailGrabber::Web do
  describe '.app' do
    let(:app) { described_class.app }

    it 'is a kind of Rack::Builder' do
      expect(app).to be_a_kind_of(Rack::Builder)
    end
  end

  describe '.call' do
    before { allow(described_class).to receive(:app).and_return(app) }

    let(:app) { class_double('Web::Application') }
    let(:env) do
      {
        'PATH_INFO' => '/',
        'REQUEST_METHOD' => 'GET',
        'SCRIPT_NAME' => '',
        'rack.input' => StringIO.new(+'')
      }
    end

    it 'calls the web application' do
      expect(app).to receive(:call).with(env)
      described_class.call(env)
    end
  end
end
