class PasswordsController < ApplicationController
    
    def v1_process_request_reset_password_link
      
      @email_provided = params[:email].downcase
      
      @existing_user = User.where(:email => @email_provided).first
      
      if @existing_user.present?
      
        #In case multiple requests have been done.
        if @existing_user.password_reset_code.present?
            #Allow this same link to be used.
        else
            @existing_user.password_reset_code = loop do
              random_uid = SecureRandom.base36(24)
          	  break random_uid unless User.exists?(password_reset_code: random_uid)
            end
    
            @existing_user.save
        end    
        
        #provide email to user.
        @recipient_name = @existing_user.first_name
        @recipient_email = @existing_user.email
        @subject = "BlogEmbed.com password reset link request"
        @body = "Hi #{@existing_user.first_name}, looks like you requested a password reset link. Please find it below:"
        @link = Rails.configuration.access_point["webserver_domain"] + "/reset_password" + "?password_reset_code=#{@existing_user.password_reset_code}"
        GeneralMailer.general_email(@recipient_name, @recipient_email, @subject, @body, @link).deliver

        #return happy path vars for now.
        render json: {:result => 'success', :message => 'Done! Please check your email for your reset link.', :payload => {}, :status => 200}  
        
      else
        
        render json: {:result => 'failure', :message => 'Hmm, seems we could not find you with this email address...', :payload => {}, :status => 200}
        
      end
      
    end
    
    def v1_process_new_password
        
      @password_provided = params[:password]
      @password_reset_code = params[:password_reset_code]
      
      @existing_user = User.where(:password_reset_code => @password_reset_code).first
      
      if @existing_user.present?
      
        @existing_user.password = params[:password]
        
        #Create db_session_token for auto login on web server.
        @existing_user.db_session_token = loop do
          random_uid = SecureRandom.base36(24)
      	  break random_uid unless User.exists?(db_session_token: random_uid)
        end
        
        #prevent additional password changes with current code.
        #@existing_user.password_reset_code = nil
        
        #save our changes.
        @existing_user.save  
        
        #return happy path vars for now.
        render json: {:result => 'success', :message => 'Your password was successfully changed and you have been logged in.', :payload => {:db_session_token => @existing_user.db_session_token}, :status => 200}

      else
        
        render json: {:result => 'failure', :message => 'Hmm, seems this reset code was already used. Password was not changed.', :payload => {}, :status => 200}
        
      end
        
    end    
    
end
