module Chat
  module Model
    class Conversation < Sequel::Model(:conversations)
      include Celluloid

      one_to_one :user1, class: :User
      one_to_one :user2, class: :User
    end
  end
end
