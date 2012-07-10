class Discussion < Sequel::Model
  many_to_one :user
  many_to_many :comments, :join_table => :discussion_comments

  def add_new_comment(text)
    Comment.create(:user_id => user.id, :text => text).tap do |comment|
      DiscussionComment.create(:discussion_id => self.id, :comment_id => comment.id)
      self.updated_at = Time.now
      save
    end
  end
end
