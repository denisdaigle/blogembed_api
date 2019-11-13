class BlogsController < ApplicationController
    
    def v1_fetch_post_for_embed
      
      if params[:post_uid].present? && params[:requesting_url].present?
        
        #Let's get the post they requested to view.
        @post = Post.where(:uid => params[:post_uid]).first
        
        if @post.present?
          
          #first, let's see what blog this post belongs to.
          @blog = @post.blog
          
          #is the requesting url allowed to access this blog post?
          domain_permitted = false
          @blog.permitted_domains.each do |domain|
            
            #Let's remopve the extra stuff people paste into the domain field, to leave the pure domain.
            @permitted_domain = domain.permitted_domain.gsub("https://", "").gsub("http://", "").gsub!("/", "")
            @requesting_url = params[:requesting_url]

            if @requesting_url == @permitted_domain
              domain_permitted = true
              break
            end
            
          end
          
          if domain_permitted
            
            #Now let's check to see if its published or in draft mode.
            if @post.status == "live"
              render json: {:result => 'success', :message => "Access permitted.", :payload => {:post => @post.content}, :status => 200}
            else
              render json: {:result => 'failure', :reason => 'draft_mode', :message => "This content is in draft mode, please check back later for an update!", :payload => {}, :status => 200}
            end  
            
          else
            render json: {:result => 'failure', :reason => 'access_denied', :message => "To view this content here, please add #{params[:requesting_url]} to your permitted domains on", :payload => {}, :status => 200}
          end  

        else  
          
          render json: {:result => 'failure', :reason => 'not_found', :message => 'This post is no longer available.', :payload => {}, :status => 200}
       
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing your session token.', :payload => {}, :status => 200}
        
      end
      
    end 
    
    def v1_save_blog_and_post_content
      
      if params[:blog_name].present? && params[:post_title].present? && params[:post_content].present? && params[:db_session_token].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?
          @blog = Blog.new(:name => params[:blog_name], :user_id => @user.id)
          @blog.uid = loop do
          	random_uid = SecureRandom.uuid
          	break random_uid unless Blog.exists?(uid: random_uid)
          end
          @blog.save
          
          @post = Post.new(:title => params[:post_title], :blog_id => @blog.id, :user_id => @user.id, :content => params[:post_content])
          @post.uid = loop do
          	random_uid = SecureRandom.uuid
          	break random_uid unless Post.exists?(uid: random_uid)
          end
          @post.save
          
          render json: {:result => 'success', :message => "Your new blog and post are ready!", :payload => {:post => @post.get_post_details}, :status => 200}
          
        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing some details', :payload => {}, :status => 200}
        
      end 
        
    end   
    
    def v1_fetch_blogs_from_database
      
      if params[:db_session_token].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?
          
          #Let's get their blogs and post previews per with UIDs to link.
          @blogs = []
          @user.blogs.order('created_at DESC').each do |blog|
            
            this_blog = blog.blog_details
            
            
            #let's get all the posts.
            blog_posts = []
            blog.posts.order('created_at DESC').each do |post|
              this_post = {}
              this_post["post_title"] = post.title
              this_post["post_uid"] = post.uid
              this_post["post_status"] = post.status
              this_post["post_content_preview"] = post.content.truncate(50)
              blog_posts << this_post
            end  
            
            #let's round these up to send.
            @blogs << [this_blog, blog_posts]
            
          end  
          
          render json: {:result => 'success', :message => "Here are you blogs and posts", :payload => {:blogs => @blogs}, :status => 200}
          
        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing your session token', :payload => {}, :status => 200}
        
      end 
      
    end  
    
    def v1_fetch_post_from_database
 
      if params[:db_session_token].present? && params[:post_uid].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?
          
          #Let's get the post they requested to view.
          @post = @user.posts.where(:uid => params[:post_uid]).first
          
          if @post.present?
            render json: {:result => 'success', :message => "Here is your post information.", :payload => {:post => @post.get_post_details}, :status => 200}
          else  
            render json: {:result => 'failure', :message => 'Sorry, we could not find this post in our database.', :payload => {}, :status => 200}
          end

        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account.', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing your session token.', :payload => {}, :status => 200}
        
      end
      
    end  
    
    def v1_fetch_blog_details_from_database
      
      if params[:db_session_token].present? && params[:blog_uid].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?
          
          #Let's get the post they requested to view.
          @blog = @user.blogs.where(:uid => params[:blog_uid]).first
          
          if @blog.present?
            render json: {:result => 'success', :message => "Here is your post information.", :payload => {:blog_details => {:blog_name => @blog.name, :blog_uid => @blog.uid}}, :status => 200}
          else  
            render json: {:result => 'failure', :message => 'Sorry, we could not find this post in our database.', :payload => {}, :status => 200}
          end

        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account.', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing your session token.', :payload => {}, :status => 200}
        
      end
      
    end  
    
    def v1_save_post_changes
    
      if params[:post_title].present? && params[:post_content].present? && params[:post_uid].present? && params[:db_session_token].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?

          #Let's get the post they requested to view.
          @post = @user.posts.where(:uid => params[:post_uid]).first
          
          if @post.present?
            
            #save post changes.
            @post.update!(:title => params[:post_title], :content => params[:post_content])
            
            render json: {:result => 'success', :message => "Here is your post information.", :payload => {:post => @post.get_post_details}, :status => 200}
          else  
            render json: {:result => 'failure', :message => 'Sorry, we could not find this post in our database.', :payload => {}, :status => 200}
          end

        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing some details', :payload => {}, :status => 200}
        
      end 
        
    end 
    
    def v1_create_post
      
      if params[:post_title].present? && params[:post_content].present? && params[:blog_uid].present? && params[:db_session_token].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?

          #Let's get the post they requested to view.
          @blog = @user.blogs.where(:uid => params[:blog_uid]).first
          
          if @blog.present?
            
            #Create post.
            @post = Post.new(:title => params[:post_title], :content => params[:post_content], :blog_id => @blog.id, :user_id => @user.id)
            @post.uid = loop do
            	random_uid = SecureRandom.uuid
            	break random_uid unless Post.exists?(uid: random_uid)
            end
            @post.save
            
            render json: {:result => 'success', :message => "Post created. Here is your post information.", :payload => {:post => @post.get_post_details}, :status => 200}
          
          else  
            
            render json: {:result => 'failure', :message => 'Sorry, we could not find thblog to post toward in our database.', :payload => {}, :status => 200}
          
          end

        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing some details', :payload => {}, :status => 200}
        
      end
      
    end  
    
    def v1_delete_post
      
      if params[:post_uid].present? && params[:db_session_token].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?

          #Let's get the post they requested to view.
          @post = @user.posts.where(:uid => params[:post_uid]).first
          
          if @post.present?
            
            #save post changes.
            @post.destroy
            
            render json: {:result => 'success', :message => "Your post was deleted successfully", :payload => {}, :status => 200}
          else  
            render json: {:result => 'failure', :message => 'Sorry, we could not find this post in our database.', :payload => {}, :status => 200}
          end

        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing some details', :payload => {}, :status => 200}
        
      end 
      
    end
    
    def v1_delete_blog
      
      if params[:blog_uid].present? && params[:db_session_token].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?

          #Let's get the post they requested to view.
          @blog = @user.blogs.where(:uid => params[:blog_uid]).first
          
          if @blog.present?
            
            #save post changes.
            @blog.destroy
            
            render json: {:result => 'success', :message => "Your blog and all its posts were deleted successfully", :payload => {}, :status => 200}
          else  
            render json: {:result => 'failure', :message => 'Sorry, we could not find this blog in our database.', :payload => {}, :status => 200}
          end

        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing some details', :payload => {}, :status => 200}
        
      end 
      
    end
    
    def v1_save_blog_details_changes
      
      if params[:db_session_token].present? && params[:blog_uid].present? && params[:blog_name].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?
          
          #Let's get the post they requested to view.
          @blog = @user.blogs.where(:uid => params[:blog_uid]).first
          
          if @blog.present?
            
            @blog.update!(:name => params[:blog_name])
            
            render json: {:result => 'success', :message => "Here is your post information.", :payload => {:blog_details => @blog.blog_details}, :status => 200}
          
          else 
            
            render json: {:result => 'failure', :message => 'Sorry, we could not find this post in our database.', :payload => {}, :status => 200}
          
          end

        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account.', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing your session token.', :payload => {}, :status => 200}
        
      end
      
    end
    
    def v1_publish_post
       
      if params[:post_uid].present? && params[:db_session_token].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?

          #Let's get the post they requested to view.
          @post = @user.posts.where(:uid => params[:post_uid]).first
          
          if @post.present?
            
            #Let's see if this user is allowed to publish this post.
            if @user.publish_counts.count >= 3 && @user.account_type == "trial" 
            
              render json: {:result => 'failure', :reason => "trial_paywall", :message => "Free trial publish limit reached. You can publish this content once you", :payload => {}, :status => 200}
            
            else
            
              #save post changes.
              @post.update!(:status => "live", :last_published => DateTime.now)
              
              #increase the publish count if this post has not yet been added.
              unless @user.publish_counts.where(:post_id => @post.id).present?
                PublishCount.create!(:user_id => @user.id, :post_id => @post.id)
              end 
            
              render json: {:result => 'success', :message => "Your post was published successfully.", :payload => {:post => @post.get_post_details}, :status => 200}

            end
            
          else  
            
            render json: {:result => 'failure', :message => 'Sorry, we could not find this post in our database.', :payload => {}, :status => 200}
          
          end

        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing some details', :payload => {}, :status => 200}
        
      end 
        
    end
    
    def v1_unpublish_post
       
      if params[:post_uid].present? && params[:db_session_token].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?

          #Let's get the post they requested to view.
          @post = @user.posts.where(:uid => params[:post_uid]).first
          
          if @post.present?
            
            #save post changes.
            @post.update!(:status => "draft", :last_published => nil)
            
            render json: {:result => 'success', :message => "This post was successfully unpublished", :payload => {:post => @post.get_post_details}, :status => 200}
          else  
            render json: {:result => 'failure', :message => 'Sorry, we could not find this post in our database.', :payload => {}, :status => 200}
          end

        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing some details', :payload => {}, :status => 200}
        
      end 
        
    end
    
    def v1_add_permitted_domain
      
      if params[:db_session_token].present? && params[:blog_uid].present? && params[:permitted_domain].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?
          
          #Let's get the post they requested to view.
          @blog = @user.blogs.where(:uid => params[:blog_uid]).first
          
          if @blog.present?
            
            #Check to see if it still exists.
            @permitted_domain =  @blog.permitted_domains.where(:permitted_domain => params[:permitted_domain]).first
            unless @permitted_domain.present?
              @permitted_domain = PermittedDomain.new(:permitted_domain => params[:permitted_domain], :blog_id => @blog.id, :user_id => @user.id)
              @permitted_domain.uid = loop do
              	random_uid = SecureRandom.uuid
              	break random_uid unless PermittedDomain.exists?(uid: random_uid)
              end
              @permitted_domain.save
            end
            
            render json: {:result => 'success', :message => "Here is your post information.", :payload => {:blog_details => @blog.blog_details}, :status => 200}
          
          else 
            
            render json: {:result => 'failure', :message => 'Sorry, we could not find this post in our database.', :payload => {}, :status => 200}
          
          end

        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account.', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing your session token.', :payload => {}, :status => 200}
        
      end
      
    end  
    
    def v1_remove_permitted_domain
      
      if params[:db_session_token].present? && params[:permitted_domain_uid].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?
          
          #Check to see if it still exists.
          @permitted_domain =  @user.permitted_domains.where(:uid => params[:permitted_domain_uid]).first
          if @permitted_domain.present?
            
            @blog = @permitted_domain.blog
            
            @permitted_domain.destroy
            
            render json: {:result => 'success', :message => "Permitted domain removed. Here is your blog details for the refresh.", :payload => {:blog_details => @blog.blog_details}, :status => 200}

          else
          
            render json: {:result => 'failure', :message => 'Sorry, we could not find this permitteds domain in our database.', :payload => {}, :status => 200}

          end

        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account.', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing your session token.', :payload => {}, :status => 200}
        
      end
      
    end
    
    def v1_fetch_blog_details
      
      if params[:db_session_token].present? && params[:blog_uid].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?
          
          #Let's get the post they requested to view.
          @blog = @user.blogs.where(:uid => params[:blog_uid]).first
          
          if @blog.present?

            render json: {:result => 'success', :message => "Here is your post information.", :payload => {:blog_details => @blog.blog_details}, :status => 200}
          
          else 
            
            render json: {:result => 'failure', :message => 'Sorry, we could not find this post in our database.', :payload => {}, :status => 200}
          
          end

        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account.', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing your session token.', :payload => {}, :status => 200}
        
      end
      
    end  
    
end
