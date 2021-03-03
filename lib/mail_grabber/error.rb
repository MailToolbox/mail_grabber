# frozen_string_literal: true

module MailGrabber
  class Error < StandardError
    # Specific error class for errors if database error happen
    class DatabaseHelperError < Error; end

    # Specific error class for errors if parameter is not given
    class WrongParameter < Error; end
  end
end
