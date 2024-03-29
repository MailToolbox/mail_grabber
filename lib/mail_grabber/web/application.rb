# frozen_string_literal: true

require 'json'

module MailGrabber
  module Web
    class Application
      extend ApplicationRouter

      include ApplicationHelper
      include DatabaseHelper

      attr_reader :request, :response

      # Method to call MailGrabber::Web::Application. This method will call the
      # initialize method and returns with response of the application.
      #
      # @param [Hash] env the environment variables
      #
      # @return [Array] the response of the web application
      #   e.g. [200, {}, ['Hello World']]
      def self.call(env)
        new(env).response.finish
      end

      # Initialize web application request and response, then process the given
      # request.
      #
      # @param [Hash] env the environment variables
      def initialize(env)
        @request = Rack::Request.new(env)
        @response = Rack::Response.new

        process_request
      end

      # Extract env['PATH_INFO'] value. If the path info is empty, then it will
      # return with root path.
      #
      # @return [String] path the requested path or the root path if this value
      #   is empty
      def path
        @path ||= request.path_info.empty? ? '/' : request.path_info
      end

      # This method returns with extracted request parameters.
      #
      # @return [Hash] params
      def params
        request.params
      end

      # Extract env['REQUEST_METHOD'] value.
      #
      # @return [String] request_method with e.g. GET, POST or DELETE etc.
      def request_method
        request.request_method
      end

      # Extract env['SCRIPT_NAME'] value.
      #
      # @return [String] script_name the initial portion of the request 'path'
      def script_name
        request.script_name
      end

      # Parse the routes of the ApplicationRouter and tries to find a matching
      # route for the request method, which was defined in the
      # get, post, put, patch or delete blocks. If the 'extracted_params' is
      # nil, then it could not find any defined routes. If it can find a defined
      # route, then it saves the params and call the given block. If it cannot
      # find anything, then it will set the response with 404 Not Found.
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
        response.write(render('index.html.erb'))
      end

      get '/messages.json' do
        result =
          if params['page'].nil? || params['per_page'].nil?
            select_all_messages
          else
            select_messages_by(params['page'], params['per_page'])
          end

        response.write(result.to_json)
      end

      get '/message/:id.json' do
        message = select_message_by(params['request_params']['id'])
        message_parts = select_message_parts_by(params['request_params']['id'])

        response.write(
          { message: message, message_parts: message_parts }.to_json
        )
      end

      delete '/messages.json' do
        delete_all_messages

        response.write({ info: 'All messages have been deleted' }.to_json)
      end

      delete '/message/:id.json' do
        delete_message_by(params['request_params']['id'])

        response.write({ info: 'Message has been deleted' }.to_json)
      end

      # Render erb template from the views folder.
      #
      # @param [String] template
      #
      # @return [String] template with the result
      def render(template)
        path = File.expand_path("views/#{template}", __dir__)
        ERB.new(File.read(path)).result(binding)
      end
    end
  end
end
