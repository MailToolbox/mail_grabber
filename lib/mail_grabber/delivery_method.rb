# frozen_string_literal: true

module MailGrabber
  class DeliveryMethod < MailPlugger::DeliveryMethod
    include DatabaseHelper

    # Catch and save messages into a database that we can check those message in
    # MailGrabber web application.
    #
    # @param [Mail::Message] message what we would like to send
    def deliver!(message)
      unless message.is_a?(Mail::Message)
        raise MailPlugger::Error::WrongParameter,
              'The given parameter is not a Mail::Message'
      end

      store_message(message)
    rescue SQLite3::Exception => e
      raise Error::DatabaseHelperError, e
    end
  end
end
