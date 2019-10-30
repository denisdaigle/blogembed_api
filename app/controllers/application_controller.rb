class ApplicationController < ActionController::API
    
    #API Gateway call
    def v1_api_check #/v1/api_check
            
        #Request comes in with Header data.    
        if request.headers["X-Api-Access-Key"].present? && request.headers["X-Api-Access-Secret"]          
          api_key_check = JSON.parse(api_key_is_valid(request.headers["X-Api-Access-Key"],request.headers["X-Api-Access-Secret"]))          
          if api_key_check["result"] == "success"            
            render json: {:result => 'success', :message => '', :payload => {}, :status => 200}     
          else
            render json: {:result => 'failure', :message => api_key_check["message"], :payload => {}, :status => 200}
          end
        else
            render json: {:result => 'failure', :message => 'You are missing valid credentials in your request header', :payload => {}, :status => 200}
        end
    
    end
    
    def v1_sign_up_stub
      
      #check for the API key.
      if request.headers["X-Api-Access-Key"].present? && request.headers["X-Api-Access-Secret"]          
        api_key_check = JSON.parse(api_key_is_valid(request.headers["X-Api-Access-Key"],request.headers["X-Api-Access-Secret"]))          
        if api_key_check["result"] == "success"            
          
          #provide email to user.
          @recipient_name = ""
          @recipient_email = params[:email]
          @subject = "Thanks for reaching out on denisdaigle.com!"
          @body = "Hello, thanks for visiting my website and reaching out. How can I help with your WebApp or SaaS project?"
          GeneralMailer.general_email(@recipient_name, @recipient_email, @subject, @body).deliver

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
    
    protected
    
    #API Gateway
    def api_key_is_valid(api_key, secret)
        #Verify the token.
        if api_key
          api_key_found_and_active = ApiAccessKey.where(:api_key => api_key, :secret => secret, :active => true).first
          if api_key_found_and_active
            return {:result => 'success', :message => 'api key is valid.'}.to_json   
          else
            return {:result => 'failure', :message => 'api key not found or not active.'}.to_json
          end
        end
    end
    
end
