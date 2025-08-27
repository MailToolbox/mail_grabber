# frozen_string_literal: true

module MailGrabber
  class Error < StandardError
    # Specific error class for errors if a database error happens.
    class DatabaseHelperError < Error; end

    # Specific error class for errors if a parameter is not given.
    class WrongParameter < Error; end
  end
end
