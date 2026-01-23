# frozen_string_literal: true

module ClashSystray
  class Systray < RubyQt6::Bando::QWidget
    q_object do
      slot "perform_export_env_action()"
    end

    def initialize
      super

      create_actions
      create_menus
      create
    end

    def show
      @systray.show
    end

    private

    def create_actions
      @export_env_action = QAction.new(QIcon.from_theme(QIcon::ThemeIcon::DocumentPrint), "Export Env", self)
      @export_env_action.triggered.connect(self, :perform_export_env_action)

      @quit_action = QAction.new(QIcon.from_theme(QIcon::ThemeIcon::ApplicationExit), "Quit", self)
      @quit_action.triggered.connect($qApp, :quit)
    end

    def create_menus
      @menu = QMenu.new("", self)

      @menu.add_action(@export_env_action)

      @menu.add_separator
      @menu.add_action(@quit_action)
    end

    def create
      @systray = QSystemTrayIcon.new(self)
      @systray.set_icon QIcon.from_theme(QIcon::ThemeIcon::MailForward)
      @systray.set_context_menu @menu
    end

    def perform_export_env_action
      action = ExportEnvAction.new
      action.perform
    end
  end
end
