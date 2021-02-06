# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailGrabber::Web::ApplicationRouter do
  let(:env) do
    {
      'REQUEST_METHOD' => request_method,
      'rack.input' => StringIO.new(+'')
    }
  end

  before do
    test_class =
      Class.new do
        extend MailGrabber::Web::ApplicationRouter

        def initialize(env)
          @request = Rack::Request.new(env)
        end

        def request_method
          @request.request_method
        end

        def route
          self.class.routes[request_method].first
        end

        get('/test') { 'GET /test' }
        post('/test/:id') { 'POST /test/:id' }
        put('/test/:id/:greeting') { 'PUT /test/:id/:greeting' }
      end
    stub_const('TestClass', test_class)
  end

  describe '#extract_params' do
    subject(:extract_params) { TestClass.new(env).route.extract_params(path) }

    context 'when path is NOT matching' do
      let(:request_method) { 'GET' }
      let(:path) { '/not_matching' }

      it 'returns with nil' do
        expect(extract_params).to be nil
      end
    end

    context 'when path is matching' do
      context 'but it does NOT have any parameters' do
        let(:request_method) { 'GET' }
        let(:path) { '/test' }

        it 'returns with empty hash' do
          expect(extract_params).to eq({})
        end
      end

      context 'and it has a request parameter' do
        let(:request_method) { 'POST' }
        let(:path) { '/test/1' }

        it 'returns with the request parameter' do
          expect(extract_params).to eq({ 'id' => '1' })
        end
      end

      context 'and it have more request parameters' do
        let(:request_method) { 'PUT' }
        let(:path) { '/test/1/hello' }

        it 'returns with the query parameter' do
          expect(extract_params).to eq({ 'id' => '1', 'greeting' => 'hello' })
        end
      end
    end
  end

  describe '.get' do
    subject(:get) { TestClass.get('/') { 'GET /' }.last }

    it 'creates a new route' do
      expect(get).to be_kind_of(Struct)
    end

    it 'has the right pattern' do
      expect(get.pattern).to eq('/')
    end

    it 'returns back with the right block' do
      expect(get.block.call).to eq('GET /')
    end
  end

  describe '.post' do
    subject(:post) { TestClass.post('/:id') { 'POST /:id' }.last }

    it 'creates a new route' do
      expect(post).to be_kind_of(Struct)
    end

    it 'has the right pattern' do
      expect(post.pattern).to eq('/:id')
    end

    it 'returns back with the right block' do
      expect(post.block.call).to eq('POST /:id')
    end
  end

  describe '.put' do
    subject(:put) { TestClass.put('/:pattern') { 'PUT /:pattern' }.last }

    it 'creates a new route' do
      expect(put).to be_kind_of(Struct)
    end

    it 'has the right pattern' do
      expect(put.pattern).to eq('/:pattern')
    end

    it 'returns back with the right block' do
      expect(put.block.call).to eq('PUT /:pattern')
    end
  end

  describe '.patch' do
    subject(:patch) { TestClass.patch('/:user') { 'PATCH /:user' }.last }

    it 'creates a new route' do
      expect(patch).to be_kind_of(Struct)
    end

    it 'has the right pattern' do
      expect(patch.pattern).to eq('/:user')
    end

    it 'returns back with the right block' do
      expect(patch.block.call).to eq('PATCH /:user')
    end
  end

  describe '.delete' do
    subject(:delete) { TestClass.delete('/:slag') { 'DELETE /:slag' }.last }

    it 'creates a new route' do
      expect(delete).to be_kind_of(Struct)
    end

    it 'has the right pattern' do
      expect(delete.pattern).to eq('/:slag')
    end

    it 'returns back with the right block' do
      expect(delete.block.call).to eq('DELETE /:slag')
    end
  end

  describe '.route' do
    subject(:route) { TestClass.route('GET', '/', &proc { 'GET /' }).last }

    it 'creates a new route' do
      expect(route).to be_kind_of(Struct)
    end

    it 'has the right pattern' do
      expect(route.pattern).to eq('/')
    end

    it 'returns back with the right block' do
      expect(route.block.call).to eq('GET /')
    end
  end

  describe '.set_route' do
    subject(:set_route) do
      TestClass.set_route('GET', '/', &proc { 'GET /' }).last
    end

    it 'creates a new route' do
      expect(set_route).to be_kind_of(Struct)
    end

    it 'has the right pattern' do
      expect(set_route.pattern).to eq('/')
    end

    it 'returns back with the right block' do
      expect(set_route.block.call).to eq('GET /')
    end
  end
end
