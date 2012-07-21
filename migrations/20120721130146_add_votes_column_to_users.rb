Sequel.migration do
  up do
    alter_table :users do
      add_column :votes, Integer, :default => 0, :null => false
    end
  end

  down do
    alter_table :users do
      drop_column :votes
    end
  end
end
