module Clash
  module Web
    class Client
      extend Forwardable

      attr_reader :secret

      def_delegators :@http, :get, :put

      def initialize(options)
        @secret = options.fetch(:secret)
        @http = Http.new(self, host: options.fetch(:host), port: options.fetch(:port))
      end

      def api
        @api ||= API.new(self)
      end
    end
  end
end
