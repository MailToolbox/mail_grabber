# frozen_string_literal: true

module MailGrabber
  module Web
    module ApplicationRouter
      NAMED_SEGMENTS_PATTERN = %r{/([^/]*):([^.:$/]+)}

      attr_reader :routes

      Route =
        Struct.new(:pattern, :block) do
          # Extract parameters from the given path. All routes have a
          # path pattern which helps to the router to find which block it should
          # execute. If the path contains request parameters like '/test/1' then
          # it will match with the '/test/:id' pattern. In this case, it will
          # return with '{"id" => "1"}' hash. If it is just a simple path like
          # '/' and it has a pattern to match, then it will return with '{}'.
          # In the other case, it will return with nil.
          #
          # @param [String] path
          #
          # @return [Hash/NilClass] with the extracted parameters, empty Hash
          #   or nil
          def extract_params(path)
            if pattern.match?(NAMED_SEGMENTS_PATTERN)
              named_pattern =
                pattern.gsub(NAMED_SEGMENTS_PATTERN, '/\1(?<\2>[^$/]+)')

              path.match(Regexp.new("\\A#{named_pattern}\\Z"))&.named_captures
            elsif path == pattern
              {}
            end
          end
        end

      # Define route method that we can define routing blocks.
      #
      # @example
      #
      #   get '/' do
      #     response.write 'Hello MailGrabber'
      #   end
      #
      # @example
      #
      #   method  pattern  block
      #     |       |        |
      #    get    '/test'  do ... end
      #
      %w[GET POST PUT PATCH DELETE].each do |method|
        define_method(method.downcase) do |pattern, &block|
          route(method, pattern, &block)
        end
      end

      # Store routes with the request method, the provided pattern and the given
      # block.
      #
      # @param [String] method e.g. GET, POST etc.
      # @param [String] pattern the path what we are looking for
      # @param [Proc] block what we will run
      def route(method, pattern, &block)
        @routes ||= {}

        set_route('HEAD', pattern, &block) if method == 'GET'
        set_route(method, pattern, &block)
      end

      # Set routes Hash with the Route object.
      #
      # @param [String] method e.g. GET, POST etc.
      # @param [String] pattern the path what we are looking for
      # @param [Proc] block what we will run
      def set_route(method, pattern, &block)
        (@routes[method] ||= []) << Route.new(pattern, block)
      end
    end
  end
end
