# frozen_string_literal: true

module ClashSystray
  module Clash
    module Web
      class Client
        extend Forwardable

        attr_reader :secret

        def_delegators :@http, :get

        def initialize(options)
          @secret = options.fetch(:secret)
          @http = Http.new(
            self,
            host: options.fetch(:host), port: options.fetch(:port),
            options: options[:http] || {}
          )
        end

        def api
          @api ||= Struct.new(:client) do
            include ::ClashSystray::Clash::Web::API
          end.new(self)
        end
      end
    end
  end
end
