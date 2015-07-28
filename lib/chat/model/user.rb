module Chat
  module Model
    class User < Sequel::Model(:users)
      one_to_many :room_messages
      one_to_many :user_messages
      one_to_many :recipient_messages, class: :UserMessage, key: :recipient_id
    end
  end
end
