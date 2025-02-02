Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_OAUTH_CLIENT_ID"],
                           ENV["GOOGLE_OAUTH_CLIENT_SECRET"],
                           image_size: 150
end