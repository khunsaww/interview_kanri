source "https://rubygems.org"

ruby "3.2.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.6"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"

# Use the Puma web server in development and test.
# Production is started with Unicorn. See config/unicorn.rb.
gem "puma", ">= 5.0"

gem "devise", "~> 4.9"
gem "devise-i18n"
gem "rails-i18n", "~> 7.0.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "web-console"
  gem "capistrano", "~> 3.19", require: false
  gem "capistrano-rails", "~> 1.6", require: false
  gem "capistrano-rbenv", "~> 2.2", require: false
  gem "capistrano-bundler", "~> 2.1", require: false
  gem "capistrano3-unicorn", require: false
end

group :production do
  gem "unicorn"
  gem "aws-sdk-s3", require: false
end

