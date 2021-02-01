# frozen_string_literal: true

module MailGrabber
  module Web
    module ApplicationHelper
      def root_path
        "#{script_name}"
      end
    end
  end
end
