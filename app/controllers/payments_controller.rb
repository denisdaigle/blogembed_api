class PaymentsController < ApplicationController
  
  def v1_process_upgrade

    if params[:db_session_token].present? && params[:stripeToken].present?
      
      @user = User.find_by_db_session_token(params[:db_session_token])
      
      if @user.present?
        
        #let's process this purchase using stripe now that we have the token.

        # Set your secret key: remember to change this to your live secret key in production
        if Rails.env == "production"
          Stripe.api_key = ENV['STRIPE_SECRET_KEY']
        else  
          Stripe.api_key = Rails.application.secrets.stripe_secret_key
        end
        
        #Let's try creating a subscription with the card provided.

        begin
          
          # This creates a new Customer
          customer = Stripe::Customer.create(
            email: @user.email,
            source: params[:stripeToken]
          )

          Stripe::Subscription.create({
            customer: customer["id"],
            items: [
              {
                plan: 'plan_GBDv9iWwnPhhk2', #from the stripe plan on the dashboard.
              },
            ],
          })

        rescue Stripe::CardError => e
        
          @error = true
        
          #Less handle what comes back from Stripe and inform the user if everything checks out.
          @error_http_status = e.http_status
          @error_type = e.error.type
          if e.error.code
            @error_code = e.error.code
          end
          if e.error.decline_code
            @decline_code = e.error.decline_code
          end  
          if e.error.message
            @error_mesage = e.error.message
          end

        rescue Stripe::RateLimitError => e
          # Too many requests made to the API too quickly
          @error = true
        rescue Stripe::InvalidRequestError => e
          # Invalid parameters were supplied to Stripe's API
          @error = true
        rescue Stripe::AuthenticationError => e
          # Authentication with Stripe's API failed
          # (maybe you changed API keys recently)
          @error = true
        rescue Stripe::APIConnectionError => e
          # Network communication with Stripe failed
          @error = true
        rescue Stripe::StripeError => e
          # Display a very generic error to the user, and maybe send
          # yourself an email
          @error = true
        rescue => e
          # Something else happened, completely unrelated to Stripe
          @error = true
        end

        unless @error.present?
          
          #Add the customer id to this user.
          @user.update!(:stripe_customer_id => customer["id"])
          @user.update!(:account_type => "hero")
          
          #Email our Hero!
          @recipient_name = @user.first_name
          @recipient_email = @user.email
          @subject = "Thanks for becoming a BlogEmbed.com Hero!"
          @body = "Thank you for purchasing the BlogEmbed.com Hero plan. Truly, this means a lot to our team and keeps us working hard!"
          GeneralMailer.hero_email(@recipient_name, @recipient_email, @subject, @body).deliver

          
          render json: {:result => 'success', :message => 'Upgrade successful. Providing new account type', :payload => {:account_type => @user.account_type}, :status => 200}

        else
          
          @reason = ""
          if @error_type.present?
            @reason = @error_type
            if @decline_code.present?
              @reason = @decline_code
            end
          end
          
          @error_mesage_to_send = ""
          if @error_mesage.present?
            @error_mesage_to_send = @error_mesage
          end  
          
          render json: {:result => 'failure', :reason => @reason, :message => @error_mesage_to_send, :payload => {}, :status => 200}
          
        end  

      else
        
        render json: {:result => 'failure', :message => 'Hmm. Seems we could not find you in our database?', :payload => {}, :status => 200}
        
      end  
      
    else
      
      if params[:db_session_token].present? && params[:stripeToken].present?
        render json: {:result => 'failure', :reason => 'missing_db_session_token', :message => 'Uh-oh, seems you are missing db_session_token is missing', :payload => {}, :status => 200}
      else
        render json: {:result => 'failure', :reason => 'missing_stripe_token', :message => 'Uh-oh, seems you are missing the card token from stripe', :payload => {}, :status => 200}
      end  
      
    end
    
  end
  
end