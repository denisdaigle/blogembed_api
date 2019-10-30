Rails.application.routes.draw do
  
  get '/v1/api_check' => 'application#v1_api_check' #For clients to verify api access
  
  post '/v1/sign_up' => 'application#v1_sign_up_stub'
  
end
