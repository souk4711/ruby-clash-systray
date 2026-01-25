# frozen_string_literal: true

module ClashSystray
  module Clash
    module Web
      class Http
        def initialize(client, options)
          @client = client
          @host = options.fetch(:host)
          @port = options.fetch(:port)
          @options = options.fetch(:options)
        end

        def get(path, options = {})
          request(:get, path, options)
        end

        private

        def request(verb, path, options)
          uri = uri_for(path)

          options[:headers] = (options[:headers] || {}).merge({
            "Authorization" => "Bearer #{@client.secret}"
          })

          begin
            response = http(@options).request(verb, uri, options)
          rescue HTTP::Error => e
            raise Exceptions::Error, e.message
          end

          parse_response(response) do |parse_as, result|
            case parse_as
            when :json
              break result if result["message"].nil?
              raise Exceptions::Error, result["message"]
            else
              result
            end
          end
        end

        def uri_for(path)
          uri_options = {scheme: "http", host: @host, port: @port, path: path}
          Addressable::URI.new(uri_options)
        end

        def http(options)
          HTTP::Client.new(HTTP::Options.new(options))
        end

        def parse_response(response)
          content_type = response.headers[:content_type]
          parse_as = {
            %r{^application/json} => :json,
            %r{^text/plain} => :plain
          }.each_with_object([]) { |match, memo| memo << match[1] if content_type&.match?(match[0]) }.first || :plain

          if parse_as == :plain
            result = begin
              parse_json_response(response)
            rescue
              nil
            end
            if result
              return yield(:json, result)
            else
              return yield(:plain, response.body)
            end
          end

          result = case parse_as
          when :json
            parse_json_response(response)
          else
            response.body
          end

          yield(parse_as, result)
        end

        def parse_json_response(response)
          JSON.parse(response.body.to_s)
        end
      end
    end
  end
end
