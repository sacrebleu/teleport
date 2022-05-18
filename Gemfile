# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "activerecord", '5.2.4.5'
gem "activemodel", '5.2.4.5'
gem "actionpack", '5.2.4.5'
gem "actionview", '5.2.4.5'
gem "activesupport", '5.2.4.5'
gem "railties", '5.2.4.5'
gem "sprockets-rails", '3.2.1'

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
gem 'responders', '2.4.1'

gem 'nokogiri', '1.13.5'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
