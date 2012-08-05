Sequel.migration do
  change do
    create_table :payments do
      primary_key :id
      foreign_key :user_id, :users, :null => false
      foreign_key :ad_id, :ads, :null => false
      String :public_id, :size => 64, :null => false
      Integer :amount, :null => false
      Boolean :refunded, :null => false, :default => false
      DateTime :created_at
      DateTime :refunded_at
      index :user_id
      index :ad_id
      index :created_at
    end
  end
end
