class Post < ApplicationRecord
    
    belongs_to :user
    belongs_to :blog
    
    def get_post_details_to_view
       
       return {:post_title => self.title, :post_content => self.content}
        
    end    
    
end
