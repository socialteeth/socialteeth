Sequel.migration do
  up do
    create_table :users do
      primary_key :id
      String :name, :null => false
      String :email, :null => false, :unique => true
      String :password_hash, :null => false
      String :permission, :null => false, :default => "normal"
      DateTime :created_at
      index :created_at
      index :email
    end
  end

  down do
    drop_table :users
  end
end
