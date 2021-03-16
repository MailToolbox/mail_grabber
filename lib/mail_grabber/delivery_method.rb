# frozen_string_literal: true

module MailGrabber
  class DeliveryMethod
    include DatabaseHelper

    # Initialize MailGrabber delivery method (Rails needs it).
    def initialize(options = {}); end

    # Catch and save messages into the database that we can check those messages
    # in MailGrabber web application.
    #
    # @param [Mail::Message] message what we would like to send
    def deliver!(message)
      unless message.is_a?(Mail::Message)
        raise Error::WrongParameter,
              'The given parameter is not a Mail::Message'
      end

      store_mail(message)
    end
  end
end
