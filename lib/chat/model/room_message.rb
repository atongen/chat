module Chat
  module Model
    class RoomMessage < Sequel::Model(:room_messages)
      many_to_one :user
      many_to_one :room
    end
  end
end
