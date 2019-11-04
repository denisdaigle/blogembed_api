class UsersController < ApplicationController
    
    before_action :validate_api_access
    
    def validate_api_access
      
      #check for the API key.
      if request.headers["X-Api-Access-Key"].present? && request.headers["X-Api-Access-Secret"]          
        api_key_check = JSON.parse(api_key_is_valid(request.headers["X-Api-Access-Key"],request.headers["X-Api-Access-Secret"]))          
        if api_key_check["result"] == "success"
          #allow access
        else
          render json: {:result => 'failure', :message => api_key_check["message"], :payload => {}, :status => 200}
        end
      else
          render json: {:result => 'failure', :message => 'You are missing valid credentials in your request header', :payload => {}, :status => 200}
      end 
      
    end  
    
    def v1_sign_up
      
      #create a user account. (no error checking yet: valid email, already existing user)
      @email_provided = params[:email].downcase
      
      @existing_user = User.where(:email => @email_provided).first
      
      unless @existing_user.present?
      
        @new_user = User.new(:email => params[:email], :status => 'pending')
        @new_user.uid = loop do
        	random_uid = SecureRandom.uuid
        	break random_uid unless User.exists?(uid: random_uid)
        end
        
        @new_user.sign_up_code = loop do
          random_uid = SecureRandom.base36(24)
      	  break random_uid unless User.exists?(sign_up_code: random_uid)
        end
        
        #required by has_secure_password to save.
        @new_user.password = SecureRandom.base36(24)
        
        @new_user.save
        
        #provide email to user.
        @recipient_name = ""
        @recipient_email = params[:email]
        @subject = "Thanks for reaching out on BlogEmbed.com!"
        @body = "Hello, thanks for visiting my website and reaching out. To get started, please confirm your account by clicking on the link below:"
        @link = Rails.configuration.access_point["webserver_domain"] + "/confirm_account" + "?sign_up_code=#{@new_user.sign_up_code}"
        GeneralMailer.general_email(@recipient_name, @recipient_email, @subject, @body, @link).deliver

        #return happy path vars for now.
        render json: {:result => 'success', :message => 'You connected successfully', :payload => {}, :status => 200}  
        
      else
        
        render json: {:result => 'failure', :message => 'Hmm, seems someone has already used this email address.', :payload => {}, :status => 200}
        
      end
      
    end
    
    def v1_validate_sign_up_code
        
        if params[:sign_up_code].present?
                    
            @user = User.where(:sign_up_code => params[:sign_up_code]).first
            
            if @user.present?
                
                #delete sign_up_code to prevent reuse.
                @user.update_attributes!(:sign_up_code => nil)
                
                #return happy path vars for now.
                render json: {:result => 'success', :message => 'Your sign up code is valid, please continue.', :payload => {:uid => @user.uid}, :status => 200}
                
            else
                
                render json: {:result => 'failure', :message => "Sorry, we couldn\'t find you with this code. Please sign up or log in if you've already been set up.", :payload => {}, :status => 200}
                
            end    
            
          
        else
            
            render json: {:result => 'failure', :message => 'You are missing valid sign up code', :payload => {}, :status => 200}
            
        end   
        
    end    
    
    def v1_save_profile_setup
      
      if params[:uid].present?
                  
        @user = User.where(:uid => params[:uid]).first
        
        if @user.present?
            
            #save profie setup data
            @user.first_name = params[:first_name]
            @user.last_name = params[:last_name]
            @user.password = params[:password]
            
            #set the user for profile set
            @user.status = "profile set"
            
            #Create db_session_token for auto login on web server.
            @user.db_session_token = loop do
              random_uid = SecureRandom.base36(24)
          	  break random_uid unless User.exists?(db_session_token: random_uid)
            end
            
            @user.save  
            
            #return happy path vars for now.
            render json: {:result => 'success', :message => 'Your profile was successfully set up, you are logged in and ready to checkout your new dashboard', :payload => {:db_session_token => @user.db_session_token}, :status => 200}
            
        else
            
            render json: {:result => 'failure', :message => "Sorry, we couldn\'t find you using the provided UID.", :payload => {}, :status => 200}
            
        end    
        
      else
          
          render json: {:result => 'failure', :message => 'You are missing valid uid', :payload => {}, :status => 200}
          
      end
      
    end  
    
    def v1_nil_db_session_token
      
      @user = User.where(:db_session_token => params[:db_session_token]).first
      if @user.present?
        @user.update_attributes!(:db_session_token => nil)
      end  
      
      #async return.
      render json: {:result => 'success', :message => "db_session_token deleted", :payload => {}, :status => 200}
      
    end  
    
    def process_login
      
      @user = User.where(:email => params[:email]).first
      if @user.present?
        if @user.authenticate(params[:password])
          #let's create a new db_session_token
          
          @user.db_session_token = loop do
            random_uid = SecureRandom.base36(24)
        	  break random_uid unless User.exists?(db_session_token: random_uid)
          end
          
          @user.save 
          
          render json: {:result => 'success', :message => 'Log in successful.', :payload => {:db_session_token => @user.db_session_token}, :status => 200}

        else
          
          render json: {:result => 'failure', :message => 'Sorry, this was not the password we were expecting', :payload => {}, :status => 200}
       
        end  
        
      else
        
        render json: {:result => 'failure', :message => 'Sorry, we could not find you with using this email address', :payload => {}, :status => 200}
     
      end 
      
    end  

    def v1_check_db_session_token
      
      if params[:db_session_token].present?
        
        if User.find_by_db_session_token(params[:db_session_token]).present?
          
          render json: {:result => 'success', :message => 'Success! db_session_token found.', :payload => {}, :status => 200}
          
        else
          
          render json: {:result => 'failure', :message => 'db_session_token not found in the db', :payload => {}, :status => 200}
          
        end  
        
      else
        
        render json: {:result => 'failure', :message => 'db_session_token is missing', :payload => {}, :status => 200}
        
      end  
      
    end  

end
