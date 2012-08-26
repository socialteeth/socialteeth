Sequel.migration do
  change do
    alter_table :ads do
      add_column :issue, String, :size => 128
    end
  end
end
