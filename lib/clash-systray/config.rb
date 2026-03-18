require_relative "config/initializers/qt6"
require_relative "config/settings"

module ClashSystray
  def self.settings
    @settings ||= Settings.new
  end
end
