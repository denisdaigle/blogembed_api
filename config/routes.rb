Rails.application.routes.draw do
  
  get '/v1/api_check' => 'application#v1_api_check' #For clients to verify api access
  
  post '/v1/sign_up' => 'users#v1_sign_up'
  
  get '/v1/validate_sign_up_code' => 'users#v1_validate_sign_up_code'
  
  post '/v1/save_profile_setup' => "users#v1_save_profile_setup"
  
  #sessions
  get '/v1/nil_db_session_token' => "users#v1_nil_db_session_token"
  post '/v1/process_login' => "users#process_login"
  get '/v1/check_db_session_token' => "users#v1_check_db_session_token"
  
  #password
  post '/v1/process_request_reset_password_link' => "passwords#v1_process_request_reset_password_link"
  post '/v1/process_new_password'  => "passwords#v1_process_new_password"
  
  #blogs
  post '/v1/save_blog_and_post_content' => "blogs#v1_save_blog_and_post_content"
  get '/v1/fetch_blogs_from_database' => "blogs#v1_fetch_blogs_from_database"
  get '/v1/fetch_post_from_database' => "blogs#v1_fetch_post_from_database"
  post '/v1/save_post_changes' => "blogs#v1_save_post_changes"
  get '/v1/delete_post' => "blogs#v1_delete_post"
  get '/v1/delete_blog' => "blogs#v1_delete_blog"
  post '/v1/create_post' => "blogs#v1_create_post"
  get '/v1/fetch_blog_details_from_database' => 'blogs#v1_fetch_blog_details_from_database'
  post '/v1/save_blog_details_changes' => 'blogs#v1_save_blog_details_changes'
  
end
