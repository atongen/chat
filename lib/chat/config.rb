require 'uri'

module Chat
  module Config

    def self.read_uri_from_env(key)
      return nil unless ENV[key]
      URI.parse(ENV[key])
    end

    def self.database_url
      return unless uri  = read_uri_from_env('POSTGRES_PORT')
      return unless db   = ENV['POSTGRES_DATABASE']
      return unless user = ENV['POSTGRES_USER']
      return unless pass = ENV['POSTGRES_PASSWORD']

      "jdbc:postgresql://#{uri.host}:#{uri.port}/#{db}?user=#{user}&password=#{pass}"
    end

    def self.rabbitmq_creds
      return unless uri = read_uri_from_env('RABBITMQ_PORT')
      return unless user = ENV['RABBITMQ_USER']
      return unless pass = ENV['RABBITMQ_PASSWORD']

      creds = { host: uri.host, port: uri.port, user: user }
      creds[:vhost] = ENV['RABBITMQ_VHOST'] if ENV['RABBITMQ_VHOST']

      creds
    end

    def self.websocket_uris
      keys = ENV.keys.select { |k| k.match(/SOCKET_\d+_PORT/) }
      keys.map { |k| read_uri_from_env(k) }
    end

  end
end
