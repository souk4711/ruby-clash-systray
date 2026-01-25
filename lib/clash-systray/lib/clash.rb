# frozen_string_literal: true

require_relative "clash/config"
require_relative "clash/exceptions"
require_relative "clash/web"

module ClashSystray
  module Clash
    CONFIG_FILE = "/home/johndoe/.local/share/clash/config.yaml"

    def self.api
      @api ||= Web::Client.new(
        host: "127.0.0.1", port: config.external_controller.split(":")[1],
        secret: config.secret
      ).api
    end

    def self.config
      @config ||= Config.load(CONFIG_FILE)
    end
  end
end
