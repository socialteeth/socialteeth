Sequel.migration do
  up do
  	create_table :ad_metadatas do
      primary_key :id
      foreign_key :ad_id, :ads
      String :email, :size => 128
      String :phone, :size => 128
      String :about_submitter, :size => 4096
      String :who, :size => 4096
      String :what, :size => 4096
      String :when, :size => 4096
      String :where, :size => 4096
      String :how, :size => 4096
      String :goal, :size => 4096
      DateTime :created_at
      DateTime :updated_at
      index :created_at
      index :updated_at
    end
    alter_table :ads do
 	    add_foreign_key :ad_metadata_id, :ad_metadatas
    end
  end

  down do
  	alter_table :ads do
  	  drop_column :ad_metadata_id
  	end
  	drop_table :ad_metadatas
  end
end
