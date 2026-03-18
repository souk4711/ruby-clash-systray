module ClashSystray
  class Settings
    def GET_clash_config_path
      default_clash_config_path
    end

    private

    def default_clash_config_path
      QDir.home.file_path(".local/share/clash/config.yaml")
    end
  end
end
