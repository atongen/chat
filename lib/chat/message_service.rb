module Chat
  class MessageService

    attr_reader :user_channels,
                :room_channels

    def initialize
      @user_channels = {}
      @room_channels = {}
    end

    def open(user, ws)
      user.update(active: true)
      user_channels[user.id] = Chat::Channel::User.new(ws, user.id)
    end

    def message(user, msg)
      begin
        case msg['type']
        when 'room_join'
          handle_room_join(user, msg)
        when 'conversation_join'
          handle_conversation_join(user, msg)
        when 'room_leave'
          handle_room_leave(user, msg)
        when 'conversation_leave'
          handle_conversation_leave(user, msg)
        when 'room_message'
          handle_room_message(user, msg)
        when 'conversation_message'
          handle_conversation_message(user, msg)
        else
          puts "Unknown message type: #{msg['type']}"
        end
      rescue => e
        puts "Error handling message: #{e.inspect}"
        puts e.backtrace.join("\n")
      end
    end

    def close(user)
      user.update(active: false)
      RoomUser.where(user_id: user.id).update(active: false)

      user_ch = user_channels[user.id]

      # leave all rooms
      room_channels.keys.each do |room_id|
        room_ch = room_channels[room_id]
        do_room_user_leave(room_ch, user_ch)
      end

      user_ch.close
      user_channels.delete(user.id)
    end

    private

    def handle_room_join(user, msg)
      user_ch = user_channels[user.id]

      room_id = msg['room_id'].to_i
      if room_channels.has_key?(room_id)
        room_ch = room_channels[room_id]
      else
        room_ch = Chat::Channel::Room.new(room_id)
        room_channels[room_id] = room_ch
      end

      room_ch.enter(user_ch)

      # update user lists
      # Chat::Model::RoomUser.room_user_ids(room_user.room_id)
      room_ch.message({
        type: 'room_message',
        user_id: 0,
        body: "#{user.name} joined the room",
        created_at: Time.now
      }.to_json)
    end

    def handle_conversation_join(user, msg)
      # sender
      user_ch = user_channels[user.id]
      recipient_id = msg['recipient_id']

      message = {
        type: 'conversation_message',
        conversation_id: msg['conversation_id'],
        body: "#{user.name} join the conversation",
        created_at: Time.now
      }.to_json

      # create conversation_message

      user_ch.message(message)
      user_ch.message(message, user_id: recipient_id)
    end

    def handle_room_leave(user, msg)
      room_id = msg['room_id'].to_i
      RoomUser.where(room_id: room_id, user_id: user.id).update(active: false)

      user_ch = user_channels[user.id]
      room_ch = room_channels[room_id]

      do_room_user_leave(room_ch, user_ch)

      # update user lists
      # Chat::Model::RoomUser.room_user_ids(room_user.room_id)
      room_ch.message({
        type: 'room_message',
        user_id: 0,
        body: "#{user.id} joined the room",
        created_at: Time.now
      }.to_json)
    end

    def handle_conversation_leave(user, msg)
      # sender
      user_ch = user_channels[user.id]
      recipient_id = msg['recipient_id']

      message = {
        type: 'conversation_message',
        conversation_id: msg['conversation_id'],
        body: "#{user.name} left the conversation",
        created_at: Time.now
      }.to_json

      # create conversation_message

      user_ch.message(message, user_id: recipient_id)
    end

    def handle_room_message(user, msg)
      room_id = msg['room_id'].to_i
      room_ch = room_channels[room_id]

      message = Chat::Model::RoomMessage.create({
        user_id: user.id,
        room_id: room_id,
        body: msg['body'],
        created_at: Time.now
      })
      room_ch.message(to_message(message))
    end

    def handle_conversation_message(user, msg)
      user_ch = user_channels[user.id]
      recipient_id = msg['recipient_id']

      message = {
        type: 'conversation_message',
        conversation_id: msg['conversation_id'],
        body: msg['body'],
        created_at: Time.now
      }.to_json

      # create conversation_message

      user_ch.message(message)
      user_ch.message(message, user_id: recipient_id)
    end

    def do_room_user_leave(room_ch, user_ch)
      room_ch.leave(user_ch)

      if room_ch.empty?
        room_ch.close
        room_channels.delete(room_ch)
      else
        # tell room we're leaving
        room_ch.message({
          type: 'room_message',
          user_id: 0,
          body: "#{user.id} left",
          created_at: Time.now
        }.to_json)
        # update user lists in room
        # Chat::Model::RoomUser.room_user_ids(room_user.room_id)
      end
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
