module Chat
  module Model
    class RoomUser < Sequel::Model(:room_users)
      many_to_one :room
      many_to_one :user

      def self.room_user_ids(room_id)
        where(room_id: room_id, active: true)
          .select_map(:user_id)
      end
    end
  end
end
