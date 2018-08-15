class Account < ActiveRecord::Base
    has_many :posts
    has_many :followers
    has_many :interact_joins, through: :posts
end