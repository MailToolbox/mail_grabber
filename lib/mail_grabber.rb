# frozen_string_literal: true

require 'mail_grabber/error'
require 'mail_grabber/database_helper'
require 'mail_grabber/delivery_method'
# If we are using this gem outside of Rails, then do not load this code.
require 'mail_grabber/railtie' if defined?(Rails)
require 'mail_grabber/version'
