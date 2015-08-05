module Chat
  module Model
    class Room < Sequel::Model(:rooms)
      one_to_many :room_users
      one_to_many :room_messages

      def user_ids
        room_users
          .where(active: true)
          .select_map(:user_id)
      end

      def validate
        super
        validates_presence :name
        validates_unique :name
      end
    end
  end
end
