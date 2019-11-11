class Blog < ApplicationRecord
    
    belongs_to :user
    has_many :posts, :dependent => :destroy
    has_many :permitted_domains, :dependent => :destroy
    
    def blog_details
        
        @blog_permitted_domains = []
        self.permitted_domains.each do |domain|
          @blog_permitted_domains << domain.permitted_domain
        end  
            
        return {:blog_name => self.name, :blog_uid => self.uid, :blog_permitted_domains => @blog_permitted_domains}
    end    
end
