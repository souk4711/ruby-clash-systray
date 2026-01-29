# frozen_string_literal: true

module ClashSystray
  module Clash
    module Web
      class Http < RubyQt6::Bando::QObject
        q_object do
          slot "on_reply_finished(QNetworkReply*)"
        end

        def initialize(client, options)
          super()

          @client = client
          @host = options.fetch(:host)
          @port = options.fetch(:port)

          @on_reply_success = {}
          @manager = QNetworkAccessManager.new
          @manager.finished.connect(self, :on_reply_finished)
        end

        def get(path, options = {})
          url = QUrl.new("http://#{@host}:#{@port}#{path}")
          set_url_query(url, options[:params])

          request = QNetworkRequest.new
          request.set_url(url)
          request.set_raw_header("Authorization", "Bearer #{@client.secret}")

          reply = @manager.get(request)
          @on_reply_success[reply._qobject_ptr] = options[:on_success]
        end

        private

        def set_url_query(url, params)
          return if params.nil?

          query = QUrlQuery.new
          params.each { |k, v| query.add_query_item(k.to_qstr, v) }
          url.set_query(query)
        end

        def on_reply_finished(reply)
          on_success = @on_reply_success.delete(reply._qobject_ptr)
          return unless reply.error == QNetworkReply::NoError

          body = reply.read_all.to_s
          on_success.call(JSON.parse(body))
        ensure
          reply.delete_later
        end
      end
    end
  end
end
