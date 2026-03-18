require_relative "clash/config"
require_relative "clash/web"

module Clash
  def self.api
    @api ||= Web::Client.new(
      host: "127.0.0.1", port: config.external_controller.split(":")[1],
      secret: config.secret
    ).api
  end

  def self.config
    @config ||= Config.load(ClashSystray.settings.GET_clash_config_path)
  end
end
