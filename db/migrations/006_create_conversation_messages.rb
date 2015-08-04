Sequel.migration do
  up do
    create_table(:conversation_messages) do
      primary_key :id
      foreign_key :conversation_id, :conversations, null: false
      foreign_key :user_id, :users, null: false
      String :body, text: true
      DateTime :created_at, null: false
      index [:conversation_id, :created_at]
    end
  end

  down do
    drop_table(:conversation_messages)
  end
end
