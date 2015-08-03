module Chat
  module Model
    class UserMessage < Sequel::Model(:user_messages)
      include Celluloid

      many_to_one :user
      many_to_one :recipient, class: :User
    end
  end
end
