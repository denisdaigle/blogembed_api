class Post < ApplicationRecord
    
    belongs_to :user
    belongs_to :blog
    
    def get_post_details
       
       return {:blog_name => self.blog.name, :post_title => self.title, :post_content => self.content, :post_uid => self.uid, :post_status => self.status}
        
    end    
    
end
