Sequel.migration do
  up do
    create_table(:rooms) do
      primary_key :id
      String :name, null: false
      DateTime :created_at, null: false
      index :name, unique: true
    end
  end

  down do
    drop_table(:rooms)
  end
end
