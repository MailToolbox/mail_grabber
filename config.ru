# frozen_string_literal: true

require 'mail_grabber/database_helper'
require 'mail_grabber/web'

use Rack::Reloader, 0
use Rack::Static,
    urls: ['/stylesheets'],
    root: 'lib/mail_grabber/web/assets'

run MailGrabber::Web
