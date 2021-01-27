# frozen_string_literal: true

module MailGrabber
  module Web
    module ApplicationHelper
      def root_path
        "#{@env["SCRIPT_NAME"]}"
      end
    end
  end
end
