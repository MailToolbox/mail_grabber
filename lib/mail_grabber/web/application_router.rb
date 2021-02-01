# frozen_string_literal: true

module MailGrabber
  module Web
    module ApplicationRouter
      attr_reader :routes

      Route =
        Struct.new(:method, :pattern, :block) do
          NAMED_SEGMENTS_PATTERN = /\/([^\/]*):([^.:$\/]+)/

          def extract_params(path)
            if pattern.match?(NAMED_SEGMENTS_PATTERN)
              p = pattern.gsub(NAMED_SEGMENTS_PATTERN, '/\1(?<\2>[^$/]+)')

              path.match(Regexp.new("\\A#{p}\\Z"))&.named_captures
            else
              {} if path == pattern
            end
          end
        end

      def get(pattern, &block)
        route('GET', pattern, &block)
      end

      def delete(pattern, &block)
        route('DELETE', pattern, &block)
      end

      def route(method, pattern, &block)
        @routes ||= {}

        set_route(method, pattern, &block)
        set_route('HEAD', pattern, &block) if method == 'GET'
      end

      def set_route(method, pattern, &block)
        (@routes[method] ||= []) << Route.new(method, pattern, block)
      end
    end
  end
end
