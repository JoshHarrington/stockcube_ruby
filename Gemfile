source 'https://rubygems.org'
ruby '>=2.5.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'

# Use Puma as the app server
gem 'puma', '~> 3.7'

# Use sass-rails for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

# Use ActiveModel has_secure_password
gem 'bcrypt',  '3.1.11'

gem 'will_paginate',  '3.1.6'

gem 'sendgrid-ruby'

gem 'dotenv-rails'

gem 'cocoon'

gem 'seed_dump', '~> 3.2', '>= 3.2.4'

gem 'fraction', '~> 0.3.2'

# Use postgres as the database for Active Record
gem 'pg', '0.20.0'

gem 'client_side_validations'

gem 'searchkick'

gem 'pgsync'
gem 'pry'

gem 'hashid-rails', '~> 1.2', '>= 1.2.1'
gem 'sprockets', '>= 3.7.2'
gem 'sinatra', '>= 2.0.2'
gem 'ffi', '>= 1.9.24'
gem 'rubyzip', '>= 1.2.2'

gem 'omniauth'
gem 'omniauth-google-oauth2'

gem "nokogiri", ">= 1.8.5"
gem "rack", ">= 2.0.6"
gem "loofah", ">= 2.2.3"

gem 'webpacker', '~> 4.2', '>= 4.2.2'
gem 'react-rails'

gem 'inky-rb', require: 'inky'
# Stylesheet inlining for email
gem 'premailer-rails'

gem 'devise'

gem "recaptcha"

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.5'
  gem 'factory_bot_rails'
  gem 'capybara'
  gem 'database_cleaner'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'foreman'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
