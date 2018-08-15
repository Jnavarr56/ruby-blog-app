class Hashtag_Join < ActiveRecord::Base
    belongs_to :post
    belongs_to :hashtag
end