module Chat
  class MessageStore
    include Celluloid

    ROOM_MESSAGE_KEYS = %w{
      room_id
      user_id
      body
      created_at
    }.map(&:to_sym)

    CONVERSATION_MESSAGE_KEYS = %w{
      conversation_id
      recipient_id
      body
      created_at
    }.map(&:to_sym)

    def room_message(data)
      params = data.select { |key, _| ROOM_MESSAGE_KEYS.include?(key) }
      Chat::Model::RoomMessage.create(params)
    end

    def conversation_message(data)
      params = data.select { |key, _| CONVERSATION_MESSAGE_KEYS.include?(key) }
      Chat::Model::ConversationMessage.create(params)
    end
  end
end
