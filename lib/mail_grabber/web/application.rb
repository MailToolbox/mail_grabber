# frozen_string_literal: true

module MailGrabber
  module Web
    class Application
      include ApplicationHelper
      include DatabaseHelper

      def self.call(env)
        new(env).response.finish
      end

      def initialize(env)
        @env = env
        @request = Rack::Request.new(env)
      end

      def response
        case @request.path_info
        when '/'
          @all_message = all_message
          Rack::Response.new(render('index.html.erb'))
        else Rack::Response.new('Not found', 404)
        end
      end

      def render(template)
        path = File.expand_path("views/#{template}", __dir__)
        ERB.new(File.read(path)).result(binding)
      end
    end
  end
end
