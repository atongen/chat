module Chat
  module Model
    class User < Sequel::Model(:users)
      one_to_many :room_messages
      one_to_many :conversation_messages
    end
  end
end
