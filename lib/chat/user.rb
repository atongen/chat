module Chat
  class User

    attr_reader :id,
                :ws,
                :ch,
                :x,
                :q

    def initialize(id, ws)
      @id = id
      @ws = ws

      @ch = ::Chat::RABBITMQ.create_channel
      @x = @ch.direct('chat.user_messages')
      @q = @ch.queue('', exclusive: true, durable: true)

      @q.bind(@x, routing_key: "#{@id}")

      @q.subscribe(block: false) do |metadata, payload|
        @ws.send(payload)
      end
    end

    def message(data)
      x.publish(data)
    end

    def close
      ch.close
    end

  end
end
