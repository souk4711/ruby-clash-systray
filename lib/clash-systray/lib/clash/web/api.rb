# frozen_string_literal: true

module ClashSystray
  module Clash
    module Web
      module API
        def proxies
          url = "/proxies"
          client.get(url)
        end

        def group_delay(group)
          url = "/group/#{group}/delay"
          client.get(url, params: {
            url: "https://www.gstatic.com/generate_204",
            timeout: 2000
          })
        end
      end
    end
  end
end
