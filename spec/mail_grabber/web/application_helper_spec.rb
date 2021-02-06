# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailGrabber::Web::ApplicationHelper do
  let(:env) do
    {
      'SCRIPT_NAME' => 'mail_grabber',
      'rack.input' => StringIO.new(+'')
    }
  end

  before do
    test_class =
      Class.new do
        include MailGrabber::Web::ApplicationHelper

        def initialize(env)
          @request = Rack::Request.new(env)
        end

        def script_name
          @request.script_name
        end
      end
    stub_const('TestClass', test_class)
  end

  describe '#root_path' do
    subject(:root_path) { TestClass.new(env).root_path }

    it 'returns with root path' do
      expect(root_path).to eq('mail_grabber')
    end
  end
end
