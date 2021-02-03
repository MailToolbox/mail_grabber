# frozen_string_literal: true

module MailGrabber
  module Web
    # Helper module for views
    module ApplicationHelper
      # This method helps us that e.g. we can load style or javascript files
      # when we are running this application standalone or in Ruby on Rails.
      def root_path
        script_name.to_s
      end
    end
  end
end
