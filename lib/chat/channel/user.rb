module Chat
  module Channel
    class User

      def initialize(id, ws)
        @id = id
        @ws = ws

        @ch = ::Chat::RABBITMQ.create_channel
        @x = @ch.direct('chat.user_messages')
        @q = @ch.queue('')

        @q.bind(@x, routing_key: "user-#{@id}")

        @q.subscribe(block: false) do |metadata, payload|
          @ws.send(payload)
        end
      end

      def message(data, options = {})
        opts = {}
        opts[:routing_key] = "user-#{options[:user_id]}" if options[:user_id]
        x.publish(data, opts)
      end

      def broadcast(data)
        room_channels.each do |room_ch|
          room_ch.message(data)
        end
      end

      def close
        ch.close
      end

    end
  end
end
