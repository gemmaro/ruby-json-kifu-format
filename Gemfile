# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'rake', '~> 13.0', require: false

group :development do
  gem 'guard-yard', '~> 2.2', require: false
  gem 'redcarpet', require: false
  gem 'yard', require: false

  gem 'guard-rubocop', '~> 1.5', require: false
  gem 'rubocop', '~> 1.24', require: false
  gem 'rubocop-rake', '~> 0.6.0', require: false
  gem 'rubocop-rspec', '~> 2.7', require: false
end

group :test do
  gem 'guard-rspec', '~> 4.7', require: false
  gem 'rspec', '~> 3.0', require: false
  gem 'simplecov', '~> 0.21.0', require: false
end
