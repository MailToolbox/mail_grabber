# frozen_string_literal: true

module MailGrabber
  module Web
    class Application
      extend ApplicationRouter

      include ApplicationHelper
      include DatabaseHelper

      attr_reader :request, :response

      def self.call(env)
        new(env).response.finish
      end

      def initialize(env)
        @request = Rack::Request.new(env)
        @response = Rack::Response.new

        process_request
      end

      def path
        @path ||= request.path_info.empty? ? '/' : request.path_info
      end

      def params
        request.params
      end

      def request_method
        request.request_method
      end

      def script_name
        request.script_name
      end

      def process_request
        self.class.routes[request_method].each do |route|
          extracted_params = route.extract_params(path)

          next unless extracted_params

          request.update_param('request_params', extracted_params)

          return instance_exec(&route.block)
        end

        response.status = 404
        response.write('Not Found')
      end

      get '/' do
        @all_message = all_message
        response.write render('index.html.erb')
      end

      get '/test/:id' do
        response.write "test id: #{params['request_params']['id'].inspect}"
      end

      def render(template)
        path = File.expand_path("views/#{template}", __dir__)
        ERB.new(File.read(path)).result(binding)
      end
    end
  end
end
