Rails.application.routes.draw do
  
  #utilities
  get '/v1/api_check' => 'application#v1_api_check' #For clients to verify api access
  
  #users
  post '/v1/sign_up' => 'users#v1_sign_up'
  get '/v1/validate_sign_up_code' => 'users#v1_validate_sign_up_code'
  post '/v1/save_profile_setup' => "users#v1_save_profile_setup"
  get '/v1/check_account_type' => "users#v1_check_account_type"
  post '/v1/send_for_help' => "users#v1_send_for_help" 

  #process_payments
  post '/v1/process_upgrade' => "payments#v1_process_upgrade"
  
  #sessions
  get '/v1/nil_db_session_token' => "users#v1_nil_db_session_token"
  post '/v1/process_login' => "users#v1_process_login"
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
  get '/v1/publish_post' => 'blogs#v1_publish_post'
  get '/v1/unpublish_post' => 'blogs#v1_unpublish_post'
  get '/v1/fetch_post_for_embed' => 'blogs#v1_fetch_post_for_embed'
  post '/v1/add_permitted_domain' => 'blogs#v1_add_permitted_domain'
  get '/v1/fetch_blog_details' => 'blogs#v1_fetch_blog_details'
  get '/v1/remove_permitted_domain' => 'blogs#v1_remove_permitted_domain'

  post '/v1/save_partial_post_content_update' => 'blogs#v1_save_partial_post_content_update'
  
end
