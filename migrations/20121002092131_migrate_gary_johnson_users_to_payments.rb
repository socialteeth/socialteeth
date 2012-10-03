Sequel.migration do
  up do
   alter_table :payments do 
      add_column :address, String, :size => 128
      add_column :occupation, String, :size => 128
      add_column :employer, String, :size => 128
      add_column :name, String, :size => 128
   end
   
   alter_table :payments do 
      pay = DB[:payments]
      usr = DB[:users]
      
      pay.each do |payrow|
        if payrow[:ad_id] == 52
          email_index = payrow[:email]
          address_index = DB[:users].where(:email => email_index).first[:address]
          occupation_index = DB[:users].where(:email => email_index).first[:occupation]
          employer_index = DB[:users].where(:email => email_index).first[:employer]
          name_index =  DB[:users].where(:email => email_index).first[:name]
          DB[:payments].where(:email => payrow[:email]).update(:address => address_index,:occupation => occupation_index,:employer => employer_index,:name => name_index)
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
