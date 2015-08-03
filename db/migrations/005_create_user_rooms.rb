Sequel.migration do
  up do
    create_table(:room_users) do
      primary_key :id
      foreign_key :room_id, :rooms
      foreign_key :user_id, :users
      String :token, size: 40, fixed: true, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      index [:room_id, :user_id], unique: true
      index :token, unique: true
    end
  end

  down do
    drop_table(:room_users)
  end
end
