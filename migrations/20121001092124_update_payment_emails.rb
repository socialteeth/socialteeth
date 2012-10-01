Sequel.migration do
  up do
   alter_table :payments do 
      add_column :email, String, :size => 128
   end
   alter_table :payments do 
      pay = DB[:payments]
      usr = DB[:users]
      
      pay.each do |payrow|
        id_index = payrow[:user_id]
        email_index = DB[:users].where(:id => id_index).first[:email]
        DB[:payments].where(:user_id => payrow[:user_id]).update(:email => email_index)
      end
      
      drop_column :user_id
    end
  end

  down do
    alter_table :payments do
      add_column :user_id, Integer
      #add_foreign_key :user_id, :users
    end
      
    alter_table :payments do 
      pay = DB[:payments]
      
      pay.each do |payrow|
        email_index = payrow[:email]
        id_index = DB[:users].where(:email => email_index).first[:id]
        DB[:payments].where(:email => payrow[:email]).update(:user_id => id_index)
      end
      
      drop_column :email
    end
  end
end
