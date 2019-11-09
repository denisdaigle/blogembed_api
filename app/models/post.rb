class Post < ApplicationRecord
    
    belongs_to :user
    belongs_to :blog
    
    def get_post_details
       
       if self.last_published.present?
           @post_last_published = self.last_published.to_formatted_s(:long)
       end       
       
       return {:blog_name => self.blog.name, :post_title => self.title, :post_content => self.content, :post_uid => self.uid, :post_status => self.status, :post_last_updated => self.updated_at.to_formatted_s(:long), :post_last_published => @post_last_published}
        
    end    
    
end
