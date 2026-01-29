# frozen_string_literal: true

module ClashSystray
  class Systray < RubyQt6::Bando::QWidget
    q_object do
      slot "on_open_dashboard_action_triggered()"
      slot "on_export_env_action_triggered()"
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
      @open_dashboard_action = QAction.new("Dashboard", self)
      @open_dashboard_action.triggered.connect(self, :on_open_dashboard_action_triggered)

      @export_env_action = QAction.new("Export Env", self)
      @export_env_action.triggered.connect(self, :on_export_env_action_triggered)

      @quit_action = QAction.new("Quit", self)
      @quit_action.triggered.connect($qApp, :quit)
    end

    def create_menus
      @menu = QMenu.new("", self)
      @menu.add_action(@open_dashboard_action)

      @separator = @menu.add_separator
      @menu.add_action(@export_env_action)

      @menu.add_separator
      @menu.add_action(@quit_action)

      create_menus_selectors
    end

    def create_menus_selectors
      @selectors_actions = []
      @proxies_actions = []

      Clash.api.proxies(on_success: ->(data) {
        selectors = data["proxies"].filter { |_, v| v["hidden"] == false }
        selectors.each do |_, selector_data|
          action = QAction.new(selector_data["name"])
          @selectors_actions << action

          action_menu = QMenu.new("", self)
          action.set_menu(action_menu)

          selector_data["all"].each do |proxy_name|
            proxy_action = action_menu.add_action(proxy_name)
            proxy_action.set_checkable(true)
            proxy_action.set_checked(selector_data["now"] == proxy_name)
            @proxies_actions << proxy_action
          end
        end

        @menu.insert_separator(@separator)
        @selectors_actions.each { |action| @menu.insert_action(@separator, action) }
      })
    end

    def create
      @systray = QSystemTrayIcon.new(self)
      @systray.set_icon QIcon.from_theme(QIcon::ThemeIcon::MailForward)
      @systray.set_context_menu @menu
    end

    def on_export_env_action_triggered
      action = ExportEnvAction.new
      action.perform
    end

    def on_open_dashboard_action_triggered
      action = OpenDashboardAction.new
      action.perform
    end
  end
end
