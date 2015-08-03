module Chat
  module Model
    class RoomMessage < Sequel::Model(:room_messages)
      include Celluloid

      many_to_one :user
      many_to_one :room
    end
  end
end
