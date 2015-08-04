module Chat
  module Model
    class Conversation < Sequel::Model(:conversations)
      one_to_one :user1, class: :User
      one_to_one :user2, class: :User
    end
  end
end
