Rails.application.routes.draw do
  
  get 'v1/api_check' => 'application#v1_api_check' #For clients to verify api access
  
end
