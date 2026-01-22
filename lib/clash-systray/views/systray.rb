# frozen_string_literal: true

module ClashSystray
  class Systray < RubyQt6::Bando::QWidget
    q_object do
    end

    def initialize
      super

      create_actions
      create_menus
      create_systray
    end

    def show
      @systray.show
    end

    private

    def create_actions
      @quit_action = QAction.new(QIcon.from_theme(QIcon::ThemeIcon::ApplicationExit), "Quit", self)
      @quit_action.triggered.connect($qApp, :quit)
    end

    def create_menus
      @menu = QMenu.new("", self)
      @menu.add_action(@quit_action)
    end

    def create_systray
      @systray = QSystemTrayIcon.new(self)
      @systray.set_icon QIcon.from_theme(QIcon::ThemeIcon::MailForward)
      @systray.set_context_menu @menu
    end
  end
end
