Sequel.migration do
  up do
    alter_table :ads do
      add_column :call_to_action, String, :size => 500
    end
  end

  down do
    alter_table :ads do
      drop_column :call_to_action
    end
  end
end
