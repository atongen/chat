module Chat
  class User

    attr_reader :model,
                :ws,
                :ch,
                :x,
                :q

    def initialize(model, ws)
      @model = model
      @ws = ws

      @ch = conn.create_channel
      @x = ch.direct('user_messages')
      @q = ch.queue('', exclusive: true)

      @q.bind(@x, routing_key: @model.id)

      @q.subscribe(block: false, ack: true) do |delivery_info, properties, body|
        data = JSON.parse(body)
        outgoing = {
          'type' => 'user_message',
          'user_id' => data['user_id'],
          'body' => data['body'],
          'created_at' => Time.now
        }
        UserMessage.async.create({
          user_id: data['user_id'],
          recipient_id: @model.id,
          body: data['body'],
          created_at: outgoing['created_at']
        })
        @ws.send(outgoing.to_json)
        @ch.acknowledge(delivery_info.delivery_tag, false)
      end
    end


  end
end
