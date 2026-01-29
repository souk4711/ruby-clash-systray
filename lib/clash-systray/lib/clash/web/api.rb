# frozen_string_literal: true

module ClashSystray
  module Clash
    module Web
      class API
        def initialize(client)
          @client = client
        end

        def GET_proxies(on_success:)
          url = "/proxies"
          @client.get(url, on_success:)
        end

        def GET_group_delay(group, on_success:)
          url = "/group/#{group}/delay"
          @client.get(url, params: {
            url: "https://www.gstatic.com/generate_204",
            timeout: 2000
          }, on_success:)
        end

        def PUT_proxies(group, proxy, on_success:)
          url = "/proxies/#{group}"
          @client.put(url, json: {
            name: proxy
          }, on_success:)
        end
      end
    end
  end
end
