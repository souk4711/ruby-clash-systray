require_relative "systray/helpers"
require_relative "systray/ui"

class Systray < RubyQt6::Bando::QWidget
  q_object do
    slot "_on_systray_menu_about_to_show()"
    slot "_on_open_dashboard_action_triggered()"
    slot "_on_export_env_action_triggered()"
    slot "_on_proxy_action_toggled(bool)"
  end

  def initialize
    super

    initialize_ui
  end

  def show
    @systray.show
  end

  private

  def _on_systray_menu_about_to_show
    update_proxies_actions_delayinfo
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
    proxy = hlpr_extract_proxy_name(sender.text)
    Clash.api.PUT_proxies(group, proxy, on_success: ->(_) {})
  end
end
