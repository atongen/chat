module Chat
  module Channel
    class User

      attr_reader :id,
                  :ws

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
        @x.publish(data, opts)
      end

      def close
        @ch.close
      end

    end
  end
end
