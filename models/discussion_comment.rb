class DiscussionComment < Sequel::Model
  one_to_one :discussion
  one_to_one :comment
end
