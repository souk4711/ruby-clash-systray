# frozen_string_literal: true

require_relative "config"
require_relative "lib"

require_relative "app/actions"
require_relative "app/views"

module ClashSystray
  class Application
    def self.run
      new.exec
    end

    def initialize
      QApplication.set_application_name("ClashSystray")

      @app = QApplication.new
      @systray = Systray.new
    end

    def exec
      @systray.show
      @app.exec
    end
  end
end
