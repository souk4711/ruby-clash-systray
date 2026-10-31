class Systray < RubyQt6::Bando::QWidget
  private

  def hlpr_extract_proxy_name(str)
    str.to_s.split(" | ")[0].strip
  end

  def hlpr_inject_proxy_name(*arr)
    arr.join(" | ")
  end
end
