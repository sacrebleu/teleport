# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "activerecord", '7.0.3.1'
gem "activemodel", '7.0.3.1'
gem "actionpack", '7.0.3.1'
gem "actionview", '7.0.3.1'
gem "activesupport", '7.0.3.1'
gem "railties", '7.0.3.1'
gem "sprockets-rails", '3.4.2'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.12'

# Reduces boot times through caching; required in config/boot.rb
# gem 'bootsnap', '>= 1.1.0', require: false
gem 'turbolinks'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-core'
  gem 'rspec-rails'
end

group :development do
  gem 'rubocop'
end

gem 'rest-client'
gem 'json_pure', '2.1.0'
gem 'mysql2', '0.5.2'
gem 'responders', '3.0.1'

gem 'nokogiri', '1.11.1'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
