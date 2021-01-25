# frozen_string_literal: true

require 'rack'
require 'erb'

module MailGrabber
  class Web
    include DatabaseHelper

    def self.call(env)
      new(env).response.finish
    end

    def initialize(env)
      @request = Rack::Request.new(env)
    end

    def response
      puts "===> @request.path: #{@request.path.inspect}"
      case @request.path
      when '/'
        @all_message = all_message
        Rack::Response.new(render('index.html.erb'))
      else Rack::Response.new('Not found', 404)
      end
    end

    def render(template)
      path = File.expand_path("web/views/#{template}", __dir__)
      ERB.new(File.read(path)).result(binding)
    end
  end
end
