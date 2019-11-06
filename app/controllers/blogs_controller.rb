class BlogsController < ApplicationController
    
    def v1_save_blog_and_post_content
       
      if params[:blog_name].present? && params[:post_title].present? && params[:post_content].present? && params[:db_session_token].present?
        
        @user = User.find_by_db_session_token(params[:db_session_token])
           
        if @user.present?
            
            #create blog
            @blog = Blog.new(:name => params[:blog_name], :user_id => @user.id)
            @blog.uid = loop do
            	random_uid = SecureRandom.uuid
            	break random_uid unless Blog.exists?(uid: random_uid)
            end
            @blog.save
            
            #create post
            @post = Post.new(:title => params[:post_title], :user_id => @user.id, :blog_id => @blog.id)
            @post.uid = loop do
            	random_uid = SecureRandom.uuid
            	break random_uid unless Post.exists?(uid: random_uid)
            end
            @post.save
            
            render json: {:result => 'success', :message => "Your new blog (uid: #{@blog.uid}) and post (uid: #{@post.uid}) are ready!", :payload => {:blog_uid => @blog.uid, :post_uid => @post.uid}, :status => 200}

        else
            
            render json: {:result => 'failure', :message => 'Sorry, we could not find you using your session token.', :payload => {}, :status => 200}
            
        end    
            
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing some details', :payload => {}, :status => 200}
        
      end 
        
    end    
    
end
