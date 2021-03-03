# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailGrabber::Web::Application do
  let(:path_info) { '/' }
  let(:query_string) { '' }
  let(:request_method) { 'GET' }
  let(:env) do
    {
      'PATH_INFO' => path_info,
      'QUERY_STRING' => query_string,
      'REQUEST_METHOD' => request_method,
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
      let(:path_info) { '/message/1.json' }

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
    subject(:request_method_method) { described_class.new(env).request_method }

    it 'returns with the request method from the given env' do
      expect(request_method_method).to eq('GET')
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

  describe 'get /' do
    subject(:get_main) { described_class.call(env) }

    let(:path_info) { '/' }

    it 'returns with an Array' do
      expect(get_main).to be_a_kind_of(Array)
    end

    it 'returns with status 200' do
      expect(get_main[0]).to eq(200)
    end

    it 'renders the template' do
      expect(get_main[2][0]).to match(/<!DOCTYPE html>/)
    end
  end

  # rubocop:disable RSpec/AnyInstance
  describe 'get /messages.json' do
    subject(:get_messages) { described_class.call(env) }

    let(:path_info) { '/messages.json' }
    let(:response) { [{ id: 1, subject: 'test', senders: 'test@test.com' }] }

    shared_examples 'an expected JSON response' do
      it 'returns with an Array' do
        expect(get_messages).to be_a_kind_of(Array)
      end

      it 'returns with status 200' do
        expect(get_messages[0]).to eq(200)
      end

      it 'renders the right JSON response' do
        expect(get_messages[2][0]).to eq(response.to_json)
      end
    end

    context 'when both page, per_page parameteres are missing' do
      before do
        allow_any_instance_of(described_class).to receive(:select_all_messages)
          .and_return(response)
      end

      it_behaves_like 'an expected JSON response'
    end

    context 'when one of the page or per_page parameteres is missing' do
      before do
        allow_any_instance_of(described_class).to receive(:select_all_messages)
          .and_return(response)
      end

      let(:query_string) { 'page=1' }

      it_behaves_like 'an expected JSON response'
    end

    context 'when page, per_page parameters are exist' do
      before do
        allow_any_instance_of(described_class).to receive(:select_messages_by)
          .and_return(response)
      end

      let(:query_string) { 'page=1&per_page=1' }

      it_behaves_like 'an expected JSON response'
    end
  end

  describe 'get /message/:id.json' do
    subject(:get_message) { described_class.call(env) }

    before do
      allow_any_instance_of(described_class).to receive(:select_message_by)
        .and_return(message)
      allow_any_instance_of(described_class)
        .to receive(:select_message_parts_by)
        .and_return(message_parts)
    end

    let(:path_info) { '/message/1.json' }
    let(:message) { { id: 1, subject: 'test', senders: 'test@test.com' } }
    let(:message_parts) { [{ id: 1, mail_id: 1, body: 'test' }] }
    let(:response) { { message: message, message_parts: message_parts } }

    it 'returns with an Array' do
      expect(get_message).to be_a_kind_of(Array)
    end

    it 'returns with status 200' do
      expect(get_message[0]).to eq(200)
    end

    it 'renders the right JSON response' do
      expect(get_message[2][0]).to eq(response.to_json)
    end
  end

  describe 'delete /messages.json' do
    subject(:delete_messages) { described_class.call(env) }

    before do
      allow_any_instance_of(described_class).to receive(:delete_all_messages)
    end

    let(:path_info) { '/messages.json' }
    let(:request_method) { 'DELETE' }

    it 'returns with an Array' do
      expect(delete_messages).to be_a_kind_of(Array)
    end

    it 'returns with status 200' do
      expect(delete_messages[0]).to eq(200)
    end

    it 'renders the right JSON response' do
      expect(delete_messages[2][0]).to eq('All messages have been deleted')
    end
  end

  describe 'delete /message/:id.json' do
    subject(:delete_message) { described_class.call(env) }

    before do
      allow_any_instance_of(described_class).to receive(:delete_message_by)
    end

    let(:path_info) { '/message/1.json' }
    let(:request_method) { 'DELETE' }

    it 'returns with an Array' do
      expect(delete_message).to be_a_kind_of(Array)
    end

    it 'returns with status 200' do
      expect(delete_message[0]).to eq(200)
    end

    it 'renders the right JSON response' do
      expect(delete_message[2][0]).to eq('Message has been deleted')
    end
  end
  # rubocop:enable RSpec/AnyInstance

  describe '#render' do
    subject(:render_method) do
      described_class.new(env).render('index.html.erb')
    end

    it 'renders the template' do
      expect(render_method).to match(/<!DOCTYPE html>/)
    end
  end
end
