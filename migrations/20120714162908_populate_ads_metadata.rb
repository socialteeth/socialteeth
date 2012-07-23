Sequel.migration do
  up do
  	# copy the :about_submitter field from the ads table to ads_metadata
  	DB[:ads].each{|ad|
  		# create a new metadata record for this ad
  		ad_metadata = DB[:ad_metadatas].insert(:about_submitter => ad[:about_submitter])
  		# copy the about_submitter field
  		DB[:ads][:id => ad[:id]].update(:ad_metadata_id => ad_metadata)
  	}
  	alter_table :ads do
  	  drop_column :about_submitter
  	end
  end

  down do
  	# copy the :about_submitter field from the ads_metadata table to ads
  	alter_table :ads do
  	  add_column :about_submitter, String, :size => 4096, :null => true
  	end
  	DB[:ads].each{|ad|
  		DB[:ads][:id => ad[:id]].update(:about_submitter => DB[:ad_metadatas][:id => ad[:ad_metadata_id]][:about_submitter])
  	}
  end
end
