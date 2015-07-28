Sequel.migration do
  up do
    create_table(:user_messages) do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :recipient_id, :users
      String :body, text: true
      DateTime :created_at, null: false
      index [:recipient_id, :user_id, :created_at]
    end
  end

  down do
    drop_table(:user_messages)
  end
end
