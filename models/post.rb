class Post < ActiveRecord::Base
    belongs_to :account
    has_many :interact_joins
    has_many :interacts, through: :interact_joins
    has_many :hashtag_joins
    has_many :hashtags, through: :hashtag_joins
end