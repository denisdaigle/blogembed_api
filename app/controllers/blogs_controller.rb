class BlogsController < ApplicationController
    
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
            
            this_blog = {}
            this_blog["blog_name"] = blog.name
            this_blog["blog_uid"] = blog.uid
            
            #let's get all the posts.
            blog_posts = []
            blog.posts.each do |post|
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
    
    def v1_publish_post
       
      if params[:post_uid].present? && params[:db_session_token].present?
        
        @user = User.where(:db_session_token => params[:db_session_token]).first
        
        if @user.present?

          #Let's get the post they requested to view.
          @post = @user.posts.where(:uid => params[:post_uid]).first
          
          if @post.present?
            
            #save post changes.
            @post.update!(:status => "live")
            
            render json: {:result => 'success', :message => "Your post was published successfully.", :payload => {:post => @post.get_post_details}, :status => 200}
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
            @post.update!(:status => "draft")
            
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
    
end
