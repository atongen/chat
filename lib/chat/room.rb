module Chat
  class Room

    attr_reader :id,
                :users,
                :ch,
                :x,
                :q

    def initialize(id)
      @id = id
      @users = {}

      @ch = ::Chat::RABBITMQ.create_channel
      @x = @ch.fanout("chat.room_messages_#{@id}")
      @q = @ch.queue('', durable: true)

      @q.bind(@x)

      @q.subscribe(block: false) do |metadata, payload|
        @users.keys.each do |ws|
          ws.send(payload)
        end
      end
    end

    def empty?
      @users.empty?
    end

    def close
      ch.close
    end

    def message(data)
      x.publish(data)
    end

    def enter(user, user_ids)
      users[user.ws] = user.id
      message({
        'type' => 'user_list',
        'user_ids' => user_ids
      }.to_json)
    end

    def leave(user, user_ids)
      users.delete(user.ws)
      message({
        'type' => 'user_list',
        'user_ids' => user_ids
      }.to_json)
    end

  end
end
