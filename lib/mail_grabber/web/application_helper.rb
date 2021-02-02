# frozen_string_literal: true

module MailGrabber
  module Web
    module ApplicationHelper
      def root_path
        script_name.to_s
      end
    end
  end
end
