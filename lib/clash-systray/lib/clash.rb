# frozen_string_literal: true

require_relative "clash/config"

module ClashSystray
  module Clash
    CONFIG_FILE = "/home/johndoe/.local/share/clash/config.yaml"

    def self.config
      @config ||= Config.load(CONFIG_FILE)
    end
  end
end
