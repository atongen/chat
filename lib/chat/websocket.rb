require 'faye/websocket'

module Chat
  class Websocket
    KEEPALIVE_TIME = 30 # in seconds

    attr_reader :message_service

    def initialize(app)
      @app = app
      @message_service = Chat::MessageService.new
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        request = Rack::Request.new(env)
        user = Chat::Model::User.where(token: request.params['token']).first

        if user
          ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })

          ws.on :open do |event|
            message_service.open(user, ws)
          end

          ws.on :message do |event|
            begin
              msg = JSON.parse(event.data)
            rescue => e
              puts "Invalid message received: #{e}"
            else
              if msg.is_a?(Hash) && msg['type'].is_a?(String)
                message_service.message(user, msg)
              else
                puts "Unknown message recieved: #{msg}"
              end
            end
          end

          ws.on :close do |event|
            message_service.close(user)
          end

          # Return async Rack response
          return ws.rack_response
        end
      end

      @app.call(env)
    end

  end
end
