require 'faye/websocket'
require 'json'
require 'pp'

module Chat
  class Websocket
    KEEPALIVE_TIME = 30 # in seconds

    def initialize(app)
      @app = app
      @rooms = {}
      @users = {}
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })
        request = Rack::Request.new(env)
        room_user = Chat::Model::RoomUser.where(token: request.params['token']).first
        room, user = get_room_and_user(room_user, ws)

        ws.on :open do |event|
          room_user.update(active: true)
          room.enter(user, Chat::Model::RoomUser.room_user_ids(room_user.room_id))
          room.message({
            type: 'room_message',
            user_id: 0,
            body: "#{user.id} joined",
            created_at: Time.now
          }.to_json)
        end

        ws.on :message do |event|
          msg = JSON.parse(event.data)
          case msg['type']
          when 'room_message'
            message = Chat::Model::RoomMessage.create({
              user_id: room_user.user_id,
              room_id: room_user.room_id,
              body: msg['body'],
              created_at: Time.now
            })
            room.message(to_message(message))
          when 'user_message'
            message = Chat::Model::UserMessage.create({
              user_id: room_user.user_id,
              recipient_id: msg['recipient_id'],
              body: msg['body'],
              created_at: Time.now
            })
            user.message(to_message(message))
          end
        end

        ws.on :close do |event|
          room_user.update(active: false)
          room.leave(user, Chat::Model::RoomUser.room_user_ids(room_user.room_id))
          user.close
          @users.delete(user.id)
          if room.empty?
            room.close
            @rooms.delete(room.id)
          else
            room.message({
              type: 'room_message',
              user_id: 0,
              body: "#{user.id} left",
              created_at: Time.now
            }.to_json)
          end
        end

        # Return async Rack response
        ws.rack_response
      else
        @app.call(env)
      end
    end

    private

    def get_room_and_user(room_user, ws)
      if @rooms.has_key?(room_user.room_id)
        room = @rooms[room_user.room_id]
      else
        room = Chat::Room.new(room_user.room_id)
        @rooms[room_user.room_id] = room
      end
      if @users.has_key?(room_user.user_id)
        user = @users[room_user.user_id]
      else
        user = Chat::User.new(room_user.user_id, ws)
        @users[room_user.user_id] = user
      end

      [room, user]
    end

    def to_message(obj)
      m = obj.values
      m[:type] = underscore(obj.class.name.split('::').last)
      m.to_json
    end

    def underscore(str)
      str.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end
