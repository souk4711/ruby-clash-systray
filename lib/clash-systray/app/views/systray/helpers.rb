class Systray < RubyQt6::Bando::QWidget
  module Helpers
    def self.extract_proxy_name(str)
      str.to_s.split(" | ")[0].strip
    end

    def self.inject_proxy_name(*arr)
      arr.join(" | ")
    end
  end
end
