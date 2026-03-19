module ClashSystray
  class Settings
    def GET_clash_config_path
      default_clash_config_path
    end

    private

    def default_clash_config_path
      candidates = [
        QDir.home.file_path(".local/share/clash/config.yaml"),
        QDir.home.file_path(".config/clash/config.yaml")
      ]
      candidates.each { |filepath| return filepath if File.exist?(filepath) }
      candidates[0]
    end
  end
end
