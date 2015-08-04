Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :name, null: false
      String :token, size: 40, fixed: true, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      index :name, unique: true
      index :token, unique: true
    end
  end

  down do
    drop_table(:users)
  end
end
