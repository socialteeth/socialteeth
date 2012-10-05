Sequel.migration do
  up do
   alter_table :payments do 
      add_column :address, String, :size => 128
      add_column :occupation, String, :size => 128
      add_column :employer, String, :size => 128
      add_column :name, String, :size => 128
    end

    alter_table :payments do
      DB[:payments].each do |payrow|
        if payrow[:ad_id] == 52
          email = payrow[:email]
          address = DB[:users].where(:email => email).first[:address]
          occupation = DB[:users].where(:email => email).first[:occupation]
          employer = DB[:users].where(:email => email).first[:employer]
          name =  DB[:users].where(:email => email).first[:name]
          DB[:payments].where(:email => email).
              update(:address => address, :occupation => occupation, :employer => employer, :name => name)
        end
      end
    end
  end


  down do 
    alter_table :payments do 
      drop_column :address
      drop_column :occupation
      drop_column :employer
      drop_column :name
    end
  end
end
