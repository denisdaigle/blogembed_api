class Blog < ApplicationRecord
    
    belongs_to :user
    has_many :posts, :dependent => :destroy
    has_many :permitted_domains, :dependent => :destroy
    
end
