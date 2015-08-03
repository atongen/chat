module Chat
  module Model
    class RoomUser < Sequel::Model(:room_users)
      many_to_one :room
      many_to_one :user
    end
  end
end
