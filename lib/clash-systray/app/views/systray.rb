require_relative "systray/helpers"

class Systray < RubyQt6::Bando::QWidget
  q_object do
    slot "_on_systray_menu_about_to_show()"
    slot "_on_open_dashboard_action_triggered()"
    slot "_on_export_env_action_triggered()"
    slot "_on_proxy_action_toggled(bool)"
  end

  def initialize
    super

    initialize_actions
    initialize_menus

    @systray = QSystemTrayIcon.new(self)
    @systray.set_icon(QApplication.window_icon)
    @systray.set_context_menu(@menu)
  end

  def show
    @systray.show
  end

  private

  def initialize_actions
    @open_dashboard_action = QAction.new("Dashboard", self)
    @open_dashboard_action.triggered.connect(self, :_on_open_dashboard_action_triggered)

    @export_env_action = QAction.new("Export Env", self)
    @export_env_action.triggered.connect(self, :_on_export_env_action_triggered)

    @quit_action = QAction.new("Quit", self)
    @quit_action.triggered.connect($qApp, :quit)
  end

  def initialize_menus
    @menu = QMenu.new("", self)
    @menu.add_action(@open_dashboard_action)

    initialize_menus_selectors

    @separator = @menu.add_separator
    @menu.add_action(@export_env_action)

    @menu.add_separator
    @menu.add_action(@quit_action)

    @menu.about_to_show.connect(self, :_on_systray_menu_about_to_show)
  end

  def initialize_menus_selectors
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
          proxy_action.toggled.connect(self, :_on_proxy_action_toggled)
          action_group.add_action(proxy_action)
          @proxies_actions << proxy_action
        end
      end

      @menu.insert_separator(@separator)
      @selectors_actions.each { |action| @menu.insert_action(@separator, action) }
    })
  end

  def _on_systray_menu_about_to_show
    @proxies_actions.each do |proxy_action|
      proxy_name = Helpers.extract_proxy_name(proxy_action.text)
      proxy_action.set_text(proxy_name)
    end

    @selectors_actions.each do |action|
      Clash.api.GET_group_delay(action.text, on_success: ->(data) {
        @proxies_actions.each do |proxy_action|
          proxy_name = Helpers.extract_proxy_name(proxy_action.text)
          proxy_delay = data[proxy_name]
          next unless proxy_delay

          text = Helpers.inject_proxy_name(proxy_name, "#{proxy_delay} ms")
          proxy_action.set_text(text)
        end
      })
    end
  end

  def _on_open_dashboard_action_triggered
    srv = OpenDashboardService.new
    srv.perform
  end

  def _on_export_env_action_triggered
    srv = ExportEnvService.new
    srv.perform
  end

  def _on_proxy_action_toggled(checked)
    return unless checked

    group = sender.parent.menu_action.text
    proxy = Helpers.extract_proxy_name(sender.text)
    Clash.api.PUT_proxies(group, proxy, on_success: ->(_) {})
  end
end
