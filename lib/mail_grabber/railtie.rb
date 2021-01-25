# frozen_string_literal: true

module MailGrabber
  class Railtie < Rails::Railtie
    initializer 'mail_grabber.add_delivery_method' do
      ActiveSupport.on_load :action_mailer do
        ActionMailer::Base.add_delivery_method(
          :mail_grabber,
          MailGrabber::DeliveryMethod
        )
      end
    end
  end
end
