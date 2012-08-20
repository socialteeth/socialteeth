Sequel.migration do
  change do
    alter_table :ads do
      add_column :media_plan, String
    end
  end
end
