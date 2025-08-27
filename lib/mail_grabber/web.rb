# frozen_string_literal: true

require 'erb'
require 'rack'

require 'mail_grabber/error'
require 'mail_grabber/database_helper'

require 'mail_grabber/web/application_helper'
require 'mail_grabber/web/application_router'
require 'mail_grabber/web/application'

module MailGrabber
  module Web
    module_function

    # Method that builds a Rack application and runs the
    # MailGrabber::Web::Application.
    def app
      @app ||= Rack::Builder.new do
        use Rack::Static,
            urls: ['/images', '/javascripts', '/stylesheets'],
            root: File.expand_path('web/assets', __dir__)

        run Web::Application
      end
    end

    # Method to call MailGrabber::Web. This method will call the app method
    # above.
    #
    # @param [Hash] env the environment variables
    def call(env)
      app.call(env)
    end
  end
end
