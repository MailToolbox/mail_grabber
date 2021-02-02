# frozen_string_literal: true

module MailGrabber
  module Web
    module ApplicationRouter
      NAMED_SEGMENTS_PATTERN = %r{/([^/]*):([^.:$/]+)}.freeze

      attr_reader :routes

      Route =
        Struct.new(:pattern, :block) do
          def extract_params(path)
            if pattern.match?(NAMED_SEGMENTS_PATTERN)
              p = pattern.gsub(NAMED_SEGMENTS_PATTERN, '/\1(?<\2>[^$/]+)')

              path.match(Regexp.new("\\A#{p}\\Z"))&.named_captures
            elsif path == pattern
              {}
            end
          end
        end

      %w[GET POST PUT PATCH DELETE].each do |method|
        define_method(method.downcase) do |pattern, &block|
          route(method, pattern, &block)
        end
      end

      def route(method, pattern, &block)
        @routes ||= {}

        set_route(method, pattern, &block)
        set_route('HEAD', pattern, &block) if method == 'GET'
      end

      def set_route(method, pattern, &block)
        (@routes[method] ||= []) << Route.new(pattern, block)
      end
    end
  end
end
