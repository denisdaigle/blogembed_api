class User < ApplicationRecord
    
    has_secure_password
    
    has_many :blogs, :dependent => :destroy
    has_many :publish_counts, :dependent => :destroy
    has_many :permitted_domains
    has_many :posts
    
end
