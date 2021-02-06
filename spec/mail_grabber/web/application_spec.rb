# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailGrabber::Web::Application do
  let(:path_info) { '/' }
  let(:env) do
    {
      'PATH_INFO' => path_info,
      'REQUEST_METHOD' => 'GET',
      'SCRIPT_NAME' => '',
      'rack.input' => StringIO.new(+'')
    }
  end

  describe '.call' do
    it 'initialize the web application' do
      expect(described_class).to receive(:new).with(env).and_call_original
      described_class.call(env)
    end
  end

  describe '#initialize' do
    subject(:init_method) { described_class.new(env) }

    it 'sets request with expected value' do
      expect(init_method.instance_variable_get('@request'))
        .to be_a_kind_of(Rack::Request)
    end

    it 'sets response with expected value' do
      expect(init_method.instance_variable_get('@response'))
        .to be_a_kind_of(Rack::Response)
    end

    # rubocop:disable RSpec/AnyInstance
    it 'calls process_request method' do
      expect_any_instance_of(described_class).to receive(:process_request)
      init_method
    end
    # rubocop:enable RSpec/AnyInstance
  end

  describe '#path' do
    subject(:path_method) { described_class.new(env).path }

    context 'when path_info is empty' do
      let(:path_info) { '' }

      it 'returns with root path' do
        expect(path_method).to eq('/')
      end
    end

    context 'when path_info does NOT empty' do
      let(:path_info) { '/test' }

      it 'returns with the given path' do
        expect(path_method).to eq('/test')
      end
    end
  end

  describe '#params' do
    subject(:params_method) { described_class.new(env).params }

    context 'when path is matching, but does NOT have any params' do
      it 'returns with params hash' do
        expect(params_method).to eq({ 'request_params' => {} })
      end
    end

    context 'when path is matching and it has params' do
      let(:path_info) { '/test/1' }

      it 'returns with params hash' do
        expect(params_method).to eq({ 'request_params' => { 'id' => '1' } })
      end
    end

    context 'when path does NOT match' do
      let(:path_info) { '/not_match' }

      it 'returns with an empty params hash' do
        expect(params_method).to eq({})
      end
    end
  end

  describe '#request_method' do
    subject(:request_method) { described_class.new(env).request_method }

    it 'returns with the request method from the given env' do
      expect(request_method).to eq('GET')
    end
  end

  describe '#script_name' do
    subject(:script_name_method) { described_class.new(env).script_name }

    it 'returns with the script name from the given env' do
      expect(script_name_method).to eq('')
    end
  end

  describe '#process_request' do
    subject(:process_request_method) do
      described_class.new(env).process_request
    end

    context 'when it finds a route' do
      it 'calls the route block' do
        expect(process_request_method).to match(/<!DOCTYPE html>/)
      end
    end

    context 'when it does NOT find any route' do
      let(:path_info) { '/not_match' }

      it 'returns with not found' do
        expect(process_request_method).to eq('Not Found')
      end
    end
  end

  describe '#render' do
    subject(:render_method) do
      described_class.new(env).render('index.html.erb')
    end

    it 'renders the template' do
      expect(render_method).to match(/<!DOCTYPE html>/)
    end
  end
end
