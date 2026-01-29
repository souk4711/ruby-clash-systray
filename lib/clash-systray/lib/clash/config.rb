# frozen_string_literal: true

module ClashSystray
  module Clash
    class Config
      attr_reader :port, :socks_port
      attr_reader :external_controller, :secret

      def self.load(file)
        new.tap { |c| c.__send__(:parse, file) }
      end

      private

      def parse(file)
        data = YAML.load_file(file)

        %w[
          port socks_port
          external_controller secret
        ].each do |key|
          instance_variable_set("@#{key}", data[key.tr("_", "-")])
        end
      end
    end
  end
end
