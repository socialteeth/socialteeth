Sequel.migration do 
 up do
   alter_table :payments do
     drop_column :user_id
     add_column :email, String, :size => 128, :null => false
   end
 end
 
  down do
   alter_table :payments do
     drop_column :email
     add_column :user_id, Integer, null => false
     add_foreign_key :user_id, :users
   end
 end
end