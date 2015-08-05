Sequel.migration do
  up do
    create_table(:room_messages) do
      primary_key :id
      foreign_key :room_id, :rooms, null: false
      foreign_key :user_id, :users, null: false
      String :body, text: true
      DateTime :created_at, null: false
      index [:room_id, :user_id, :created_at]
    end
  end

  down do
    drop_table(:room_messages)
  end
end
