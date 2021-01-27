# frozen_string_literal: true

require 'mail_grabber/web'

use Rack::Reloader, 0

run MailGrabber::Web
