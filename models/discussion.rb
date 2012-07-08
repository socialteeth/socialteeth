class Discussion < Sequel::Model
  many_to_one :user
  many_to_many :comments, :join_table => :discussion_comments
end
