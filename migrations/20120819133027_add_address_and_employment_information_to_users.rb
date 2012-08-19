# Some content creators (e.g., real political campaigns) are required to collect certain information from
# their contributors. This lets us provide it them.
Sequel.migration do
  change do
    alter_table :users do
      add_column :address, String, :size => 128
      add_column :occupation, String, :size => 128
      add_column :employer, String, :size => 128
    end
  end
end
