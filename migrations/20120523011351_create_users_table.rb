Sequel.migration do
  up do
    create_table :users do
      primary_key :id
      String :public_id, :size => 64, :null => false
      String :name, :size => 128, :null => false
      String :email, :size => 128, :null => false, :unique => true
      String :password_hash, :size => 128, :null => false
      String :permission, :size => 128, :null => false, :default => "normal"
      DateTime :created_at
      index :public_id
      index :email
      index :created_at
    end
  end

  down do
    drop_table :users
  end
end
