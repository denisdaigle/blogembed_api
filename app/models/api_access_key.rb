class ApiAccessKey < ApplicationRecord

  after_create :generate_initial_key_and_secret #ApiAccessKey.create!(:client_name => 'BlogEmbed Web Server')
    
  def generate_initial_key_and_secret
    api_key = ""
    secret = ""
    loop do
      api_key = "api_key_" + SecureRandom.base64.tr('+/=', 'Qrt')
      break api_key unless ApiAccessKey.exists?(api_key: api_key).present?
    end
    loop do
      secret = "secret_" + SecureRandom.base64.tr('+/=', 'Qrt')
      break secret unless ApiAccessKey.exists?(secret: secret).present?
    end    
    
    #create new keys.
    self.update!(:api_key => api_key, :secret => secret, :active => true)
    puts "#{self.client_name}'s new key: #{api_key} secret: #{secret}"
  
  end
    
end
