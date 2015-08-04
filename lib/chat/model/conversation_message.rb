module Chat
  module Model
    class UserMessage < Sequel::Model(:conversation_messages)
      include Celluloid

      many_to_one :user
      many_to_one :conversation
    end
  end
end
