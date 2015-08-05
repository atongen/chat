module Chat
  module Model
    class ConversationMessage < Sequel::Model(:conversation_messages)
      many_to_one :recipient, class: :"Chat::Model::User"
      many_to_one :conversation
    end
  end
end
