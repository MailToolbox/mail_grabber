# frozen_string_literal: true

module MailGrabber
  class Error < StandardError
    # Specific error class for errors if database error happen
    class DatabaseHelperError < Error; end
  end
end
