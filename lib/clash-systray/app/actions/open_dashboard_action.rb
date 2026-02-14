module ClashSystray
  class OpenDashboardAction
    def perform
      config = Clash.config
      port = config.external_controller.split(":")[1]
      url = "http://127.0.0.1:#{port}/ui/?host=127.0.0.0.1&port=#{port}&secret=#{config.secret}"
      view = QWebEngineView.new
      view.set_attribute(Qt::WA_DeleteOnClose)
      view.load(QUrl.new(url))
      view.show_maximized
    end
  end
end
