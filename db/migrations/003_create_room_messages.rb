Sequel.migration do
  up do
    create_table(:room_messages) do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :room_id, :rooms
      String :body, text: true
      DateTime :created_at, null: false
      index [:room_id, :user_id, :created_at]
    end
  end

  down do
    drop_table(:room_messages)
  end
end
