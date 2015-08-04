Sequel.migration do
  up do
    create_table(:conversations) do
      primary_key :id
      foreign_key :user1_id, :users, null: false
      foreign_key :user2_id, :users, null: false
      DateTime :created_at, null: false
      index [:user1_id, :user2_id], unique: true
    end
  end

  down do
    drop_table(:conversations)
  end
end
