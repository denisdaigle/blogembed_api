Rails.application.routes.draw do
  
  get '/v1/api_check' => 'application#v1_api_check' #For clients to verify api access
  
  post '/v1/sign_up' => 'users#v1_sign_up'
  
  get '/v1/validate_sign_up_code' => 'users#v1_validate_sign_up_code'
  
  post '/v1/save_profile_setup' => "users#v1_save_profile_setup"
  
end
