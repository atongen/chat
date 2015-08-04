Sequel.migration do
  up do
    create_table(:room_users) do
      primary_key :id
      foreign_key :room_id, :rooms, null: false
      foreign_key :user_id, :users, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      index [:room_id, :user_id], unique: true
    end
  end

  down do
    drop_table(:room_users)
  end
end
