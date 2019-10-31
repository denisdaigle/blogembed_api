class UsersController < ApplicationController
    
    def v1_sign_up
      
      #check for the API key.
      if request.headers["X-Api-Access-Key"].present? && request.headers["X-Api-Access-Secret"]          
        api_key_check = JSON.parse(api_key_is_valid(request.headers["X-Api-Access-Key"],request.headers["X-Api-Access-Secret"]))          
        if api_key_check["result"] == "success"            
          
          #create a user account. (no error checking yet: valid email, already existing user)
          @email_provided = params[:email]
          @new_user = User.new(:email => params[:email], :status => 'pending')
          @new_user.uid = loop do
        	random_uid = SecureRandom.uuid
        	break random_uid unless User.exists?(uid: random_uid)
          end
          
          @new_user.sign_up_code = loop do
            random_uid = SecureRandom.base36(24)
        	break random_uid unless User.exists?(sign_up_code: random_uid)
          end
          
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
          render json: {:result => 'failure', :message => api_key_check["message"], :payload => {}, :status => 200}
        end
      else
          #oops.
          render json: {:result => 'failure', :message => 'You are missing valid credentials in your request header', :payload => {}, :status => 200}
      end
      
    end
    
    def v1_validate_sign_up_code
        
        #check for the API key.
        if request.headers["X-Api-Access-Key"].present? && request.headers["X-Api-Access-Secret"]          
            
            api_key_check = JSON.parse(api_key_is_valid(request.headers["X-Api-Access-Key"],request.headers["X-Api-Access-Secret"]))          
            
            if api_key_check["result"] == "success"            
              
                if params[:sign_up_code].present?
                    
                    @user = User.where(:sign_up_code => params[:sign_up_code]).first
                    
                    if @user.present?
                        
                        #return happy path vars for now.
                        render json: {:result => 'success', :message => 'Your sign up code is valid, please continue.', :payload => {}, :status => 200}
                        
                    else
                        
                        render json: {:result => 'failure', :message => "Sorry, we couldn\'t find you with this code, are you already setup?", :payload => {}, :status => 200}
                        
                    end    
                    
                  
                else
                    
                    render json: {:result => 'failure', :message => 'You are missing valid sign up code', :payload => {}, :status => 200}
                    
                end    
              
            else
                
              render json: {:result => 'failure', :message => api_key_check["message"], :payload => {}, :status => 200}
            
            end
            
        else

          render json: {:result => 'failure', :message => 'You are missing valid credentials in your request header', :payload => {}, :status => 200}
       
        end    
        
    end    
    
end
