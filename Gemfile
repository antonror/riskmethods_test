# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'pg'
gem 'rails', '~> 6.0.3', '>= 6.0.3.4'

group :development, :test do
  gem 'ci_reporter_rspec'
  gem 'db-query-matchers'
  gem 'factory_bot_rails'
  gem 'pry'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end
