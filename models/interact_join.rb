class Interact_Join < ActiveRecord::Base
    belongs_to :post
    belongs_to :interact
    belongs_to :account
end