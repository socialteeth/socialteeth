Sequel.migration do
  up do
    create_table :comments do
      primary_key :id
      foreign_key :user_id, :users, :null => false
      String :public_id, :size => 64, :null => false
      String :text
      DateTime :created_at
      index :user_id
      index :public_id
      index :created_at
    end
  end

  down do
    drop_table :comments
  end
end
