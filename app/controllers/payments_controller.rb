class PaymentsController < ApplicationController
  
  def v1_process_upgrade

    if params[:db_session_token].present? && params[:stripeToken].present?
      
      @user = User.find_by_db_session_token(params[:db_session_token])
      
      if @user.present?
        
        #let's process this purchase using stripe now that we have the token.

        # Set your secret key: remember to change this to your live secret key in production
        Stripe.api_key = Rails.application.secrets.stripe_secret_key
      
        # This creates a new Customer
        customer = Stripe::Customer.create(
          email: @user.email
        )

        #Add the customer id to this user.
        @user.update!(:stripe_customer_id => customer.id?)

        subscription = Stripe::Subscription.create(
          customer: customer.id?,
          items: [
            {
              plan: 'plan_GB6sbY5DJcghgu' #created plan in stripe dashboard.
            }
          ],
          expand: ['latest_invoice.payment_intent']
        )
        
        
        
        #@user.update!(:account_type => "hero")
        
        render json: {:result => 'success', :message => 'Upgrade successful. Providing new account type', :payload => {:account_type => @user.account_type}, :status => 200}
        
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
