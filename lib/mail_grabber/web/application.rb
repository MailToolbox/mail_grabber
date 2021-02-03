# frozen_string_literal: true

module MailGrabber
  module Web
    class Application
      extend ApplicationRouter

      include ApplicationHelper
      include DatabaseHelper

      attr_reader :request, :response

      # Method to call MailGrabber::Web::Application. This method will call the
      # initialize method and returns back with response of the application.
      #
      # @param [Hash] env the environment variables
      def self.call(env)
        new(env).response.finish
      end

      # Initialize web application request and response then process the given
      # request.
      #
      # @param [Hash] env the environment variables
      def initialize(env)
        @request = Rack::Request.new(env)
        @response = Rack::Response.new

        process_request
      end

      # Extract env['PATH_INFO'] value. If the path info is empty then it will
      # return with root path.
      #
      # @return [String] path the requested path or root if this value is empty
      def path
        @path ||= request.path_info.empty? ? '/' : request.path_info
      end

      # This method returns back with extracted request parameters.
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
      # @return [String] script_name the initial portion of the request "path"
      def script_name
        request.script_name
      end

      # Parse the routes of the ApplicationRouter and tries to find matching
      # route for the request method, which was defined in the
      # get, post, put, patch or delete blocks. If the 'extracted_params' is nil
      # then it could not found any defined routes. If can find a defined route
      # then it saves the params and call the given block. If it cannot find
      # anything the it will set response with 404 Not Found.
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
        response.write(render('index.html.erb'))
      end

      get '/test/:id' do
        response.write("test id: #{params['request_params']['id'].inspect}")
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
