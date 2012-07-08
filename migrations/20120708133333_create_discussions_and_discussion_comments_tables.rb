Sequel.migration do
  up do
    create_table :discussions do
      primary_key :id
      foreign_key :user_id, :users, :null => false
      String :public_id, :size => 64, :null => false
      String :title, :size => 128, :null => false
      DateTime :created_at
      DateTime :updated_at
      index :created_at
      index :updated_at
    end

    create_table :discussion_comments do
      primary_key :id
      foreign_key :discussion_id, :discussions, :null => false
      foreign_key :comment_id, :comments, :null => false
    end
  end

  down do
    drop_table :discussion_comments
    drop_table :discussions
  end
end
