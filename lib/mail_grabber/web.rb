# frozen_string_literal: true

require 'erb'
require 'rack'

require 'mail_grabber/database_helper'

require 'mail_grabber/web/application_helper'
require 'mail_grabber/web/application_router'
require 'mail_grabber/web/application'

module MailGrabber
  module Web
    module_function

    def app
      @app ||= Rack::Builder.new do
        use Rack::Static,
            urls: ['/stylesheets'],
            root: File.expand_path('web/assets', __dir__)

        run Web::Application
      end
    end

    def call(env)
      app.call(env)
    end
  end
end
