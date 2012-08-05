class Payment < Sequel::Model
  many_to_one :user
  many_to_one :ad
end
