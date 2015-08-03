module Chat
  class Room

    attr_reader :model,
                :users,
                :ch,
                :x,
                :q

    def initialize(model)
      @model = model
      @users = []

      @ch = Chat::RABBITMQ.create_channel
      @x = ch.fanout('room_messages')
      @q = ch.queue('', durable: true)

      @q.bind(@x)

      @q.subscribe(block: false, ack: true) do |delivery_info, properties, body|
        data = JSON.parse(body)
        case data['type']
        when 'room_message'
          outgoing = {
            'type' => 'room_message',
            'user_id' => data['user_id'],
            'body' => data['body'],
            'created_at' => data['created_at']
          }
        when 'user_list'
          outgoing = {
            'type' => 'user_list',
            'user_ids' => data['user_ids']
          }
        end
        @users.each do |user|
          user.ws.send(outgoing)
        end
        @ch.ack(delivery_info.delivery_tag, false)
      end
    end

    def enter(user)
      users << user
      x.publish({
        'type' => 'user_list',
        'user_ids' => @model.select_map(:user_id)
      }.to_json)
    end

    def leave(user)
      users.delete(user)
      x.publish({
        'type' => 'user_list',
        'user_ids' => @model.select_map(:user_id)
      }.to_json)
    end

    private

    def handle_room_message(data)
      RoomMessage.async.create({
        user_id: data['user_id'],
        room_id: @model.id,
        body: data['body'],
        created_at: outgoing['created_at']
      })
      outgoing
    end

    def handle_user_list(data)
    end

  end
end
