Sequel.migration do
  up do
    add_column :payments, :email, String, :size => 128

    DB[:payments].each do |payrow|
      user_id = payrow[:user_id]
      email = DB[:users].where(:id => user_id).first[:email]
      DB[:payments].where(:user_id => user_id).update(:email => email)
    end

    drop_column :payments, :user_id
  end

  down do
    add_column :payments, :user_id, Integer

    DB[:payments].each do |payrow|
      email = payrow[:email]
      user_id = DB[:users].where(:email => email).first[:id]
      DB[:payments].where(:email => email).update(:user_id => user_id)
    end

    alter_table :payments do
      add_foreign_key :user_id, :users

      drop_column :email
    end
  end
end
