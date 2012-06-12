Sequel.migration do
  up do
    DB.run "CREATE TYPE ad_type AS ENUM ('video', 'audio', 'image')"
    create_table :ads do
      primary_key :id
      foreign_key :user_id, :users, :null => false
      String :public_id, :size => 64, :null => false
      String :title, :size => 128, :null => false
      String :description, :size => 4096, :null => false
      String :about_submitter, :size => 4096, :null => false
      Integer :goal, :null => false
      ad_type :ad_type, :null => false
      String :url, :size => 2083
      String :thumbnail_url, :size => 2083
      Boolean :is_published, :null => false, :default => false
      DateTime :deadline, :null => false
      DateTime :created_at
      index :user_id
      index :public_id
      index :created_at
    end
  end

  down do
    drop_table :ads
    DB.run "DROP TYPE ad_type"
  end
end
