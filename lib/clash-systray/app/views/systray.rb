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
      create_selector_actions

      @export_env_action = QAction.new(QIcon.from_theme(QIcon::ThemeIcon::DocumentPrint), "Export Env", self)
      @export_env_action.triggered.connect(self, :perform_export_env_action)

      @quit_action = QAction.new(QIcon.from_theme(QIcon::ThemeIcon::ApplicationExit), "Quit", self)
      @quit_action.triggered.connect($qApp, :quit)
    end

    def create_selector_actions
      return if @selector_actions_data

      selectors = Clash.api.proxies["proxies"].filter { |_, v| v["hidden"] == false }
      @selector_actions_data = selectors.map do |_, v|
        create_selector_action(v)
      end
    end

    def create_selector_action(data)
      action = QAction.new(data["name"], self)

      proxy_actions_data = data["all"].map do |proxy_name|
        proxy_action = QAction.new(proxy_name, self)
        proxy_action.set_checkable(true)
        proxy_action.set_checked(data["now"] == proxy_name)
        {action: proxy_action}
      end

      {action:, proxy_actions_data:}
    end

    def create_menus
      @menu = QMenu.new("", self)

      @menu.add_separator
      @selector_actions_data.each do |selector_action_data|
        action = selector_action_data[:action]
        @menu.add_action(action)

        action_menu = QMenu.new("", self)
        selector_action_data[:proxy_actions_data].each do |proxy_action_data|
          proxy_action = proxy_action_data[:action]
          action_menu.add_action(proxy_action)
        end
        action.set_menu(action_menu)
      end

      @menu.add_separator
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
