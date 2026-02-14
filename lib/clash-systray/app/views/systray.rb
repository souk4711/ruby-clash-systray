module ClashSystray
  class Systray < RubyQt6::Bando::QWidget
    q_object do
      slot "on_open_dashboard_action_triggered()"
      slot "on_export_env_action_triggered()"
      slot "on_proxy_action_toggled(bool)"
      slot "on_systray_menu_about_to_show()"
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

      create_menus_selectors

      @separator = @menu.add_separator
      @menu.add_action(@export_env_action)

      @menu.add_separator
      @menu.add_action(@quit_action)

      @menu.about_to_show.connect(self, :on_systray_menu_about_to_show)
    end

    def create_menus_selectors
      @selectors_actions = []
      @proxies_actions = []

      Clash.api.GET_proxies(on_success: ->(data) {
        selectors = data["proxies"].filter { |_, v| v["hidden"] == false }
        selectors.each do |_, selector_data|
          action = QAction.new(selector_data["name"])
          @selectors_actions << action

          action_menu = QMenu.new("", self)
          action.set_menu(action_menu)

          action_group = QActionGroup.new(self)
          selector_data["all"].each do |proxy_name|
            proxy_action = action_menu.add_action(proxy_name)
            proxy_action.set_checkable(true)
            proxy_action.set_checked(selector_data["now"] == proxy_name)
            proxy_action.toggled.connect(self, :on_proxy_action_toggled)
            action_group.add_action(proxy_action)
            @proxies_actions << proxy_action
          end
        end

        @menu.insert_separator(@separator)
        @selectors_actions.each { |action| @menu.insert_action(@separator, action) }
      })
    end

    def create
      @systray = QSystemTrayIcon.new(self)
      @systray.set_icon QIcon.new("/usr/share/icons/Colloid-Light/apps/scalable/clash.svg")
      @systray.set_context_menu @menu
    end

    def on_open_dashboard_action_triggered
      action = OpenDashboardAction.new
      action.perform
    end

    def on_export_env_action_triggered
      action = ExportEnvAction.new
      action.perform
    end

    def on_proxy_action_toggled(checked)
      return unless checked

      group = sender.parent.menu_action.text
      proxy = h_strip_proxy_name(sender.text)
      Clash.api.PUT_proxies(group, proxy, on_success: ->(_) {})
    end

    def on_systray_menu_about_to_show
      @proxies_actions.each do |proxy_action|
        proxy_name = h_strip_proxy_name(proxy_action.text)
        proxy_action.set_text(proxy_name)
      end

      @selectors_actions.each do |action|
        Clash.api.GET_group_delay(action.text, on_success: ->(data) {
          @proxies_actions.each do |proxy_action|
            proxy_name = h_strip_proxy_name(proxy_action.text)
            proxy_delay = data[proxy_name]
            proxy_action.set_text("#{proxy_name} | #{proxy_delay} ms") if proxy_delay
          end
        })
      end
    end

    def h_strip_proxy_name(name)
      name.to_s.split(" | ")[0].strip
    end
  end
end
