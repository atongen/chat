require 'faye/websocket'
require 'json'

module Chat
  class Websocket
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app   = app
      @users = []
      @rooms = []
    end

    def call(env)
      request = Rack::Request.new(env)
      room_user = Chat::Model::RoomUser.where(token: request.params['token'], active: true).eager(:room, :user).first

      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })
        user = Chat::User.new(room_user.user, ws)
        room = Chat::Room.new(room_user.room)

        ws.on :open do |event|
          @users << user
          @rooms << room
          room_user.async.update(active: true)
          room.enter(user)
        end

        ws.on :message do |event|
          msg = JSON.parse(event.data)
          case msg['type']
          when 'room_message'

          when 'user_message'

          end
        end

        ws.on :close do |event|
          room_user.async.update(active: false)
          room.leave(user)
        end

        # Return async Rack response
        ws.rack_response
      else
        @app.call(env)
      end
    end
  end
end
