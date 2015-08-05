module Chat
  module Channel
    class Room

      attr_reader :id,
                  :user_channels

      def initialize(id)
        @id = id
        @user_channels = []

        @ch = ::Chat::RABBITMQ.create_channel
        @x = @ch.fanout("chat.room_messages_#{@id}")
        @q = @ch.queue('')

        @q.bind(@x)

        @q.subscribe(block: false) do |metadata, payload|
          @user_channels.each do |user_ch|
            user_ch.ws.send(payload)
          end
        end
      end

      def empty?
        user_channels.empty?
      end

      def close
        @ch.close
      end

      def message(data)
        @x.publish(data)
      end

      def enter(user_channel)
        user_channels << user_channel
      end

      def leave(user_channel)
        user_channels.delete(user_channel)
      end

    end
  end
end
