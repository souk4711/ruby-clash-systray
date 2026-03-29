class ExportEnvService
  def perform
    config = Clash.config
    http_proxy = "http://127.0.0.1:#{config.port}"
    socks5_proxy = "socks5h://127.0.0.1:#{config.socks_port}"
    text = "export HTTP_PROXY=#{http_proxy} HTTPS_PROXY=#{http_proxy} ALL_PROXY=#{socks5_proxy}"
    QProcess.execute("qdbus", QStringList.new << "org.kde.klipper" << "/klipper" << "setClipboardContents" << text)
  end
end
