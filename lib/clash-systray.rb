# frozen_string_literal: true

require "qt6/qtwidgets"

require_relative "clash-systray/config"
require_relative "clash-systray/views"
require_relative "clash-systray/version"

module ClashSystray
  class Application
    def self.run
      new.exec
    end

    def initialize
      @app = QApplication.new
      @systray = Systray.new
    end

    def exec
      @systray.show
      @app.exec
    end
  end
end
