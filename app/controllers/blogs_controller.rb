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
          
          render json: {:result => 'success', :message => "Your new blog and post are ready!", :payload => {:post => {:blog_name => @blog.name, :post_title => @post.title, :post_content => @post.content, :post_uid => @post.uid}}, :status => 200}
          
        else
          
          render json: {:result => 'failure', :message => 'Sorry, we could not find your user account', :payload => {}, :status => 200}
        
        end  
         
      else
        
        render json: {:result => 'failure', :message => 'Looks like you are missing some details', :payload => {}, :status => 200}
        
      end 
        
    end    
    
end
