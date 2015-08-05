module Chat
  module Model
    class Conversation < Sequel::Model(:conversations)
      one_to_many :conversation_messages

      many_to_one :user1, class: :"Chat::Model::User"
      many_to_one :user2, class: :"Chat::Model::User"
    end
  end
end
