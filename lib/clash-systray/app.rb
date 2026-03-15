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
      @app = QApplication.new
      @systray = Systray.new
    end

    def exec
      Contrib::SigHandler.new(@app)

      @systray.show
      @app.exec
    end
  end
end
