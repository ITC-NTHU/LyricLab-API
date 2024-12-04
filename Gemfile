# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Configuration and Utilities
gem 'figaro', '~> 1.2'
gem 'pry'
gem 'rack-test'
gem 'rake'

# gpt language
gem 'rest-client', '~> 2.1'
gem 'ruby-openai', '~> 6.3'

# APPLICATION LAYER
# Web application related
gem 'logger', '~> 1.6'
gem 'multi_json', '~> 1.15'
gem 'ostruct', '~> 0.0'
gem 'puma', '~> 6.0'
gem 'rack-session', '~> 0.3'
gem 'roar', '~> 1.0'
gem 'roda', '~> 3.0'

# Controllers and services
gem 'dry-monads', '~> 1.4'
gem 'dry-transaction', '~> 0.13'
gem 'dry-validation', '~> 1.7'

# Caching
gem 'rack-cache', '~> 1.13'
gem 'redis', '~> 4.8'
gem 'redis-rack-cache', '~> 2.2'

# DOMAIN LAYER
# Validation
gem 'dry-struct', '~> 1.6'
gem 'dry-types', '~> 1.7'

# INFRASTRUCTURE LAYER
# Networking
gem 'http', '~> 5.2.0'

# Google API
gem 'google-cloud-translate-v2'

# Database
gem 'hirb'
# gem 'hirb-unicode' # incompatible with new rubocop
gem 'sequel', '~> 5.0'

# Word Processing
gem 'csv'
gem 'rexml', '>= 3.3.9'
gem 'tradsim'

group :development, :test do
  gem 'roo'
  gem 'sqlite3', '~> 1.0'
end

group :production do
  gem 'pg', '~> 1.2'
end

# Testing
group :test do
  gem 'minitest', '~> 5.20'
  gem 'minitest-rg', '~> 5.2'
  gem 'simplecov', '~> 0'
  gem 'vcr', '~> 6'
  gem 'webmock', '~> 3'
end

# Development
group :development do
  gem 'flog'
  gem 'reek'
  gem 'rerun'
  gem 'rubocop'
  gem 'rubocop-minitest'
  gem 'rubocop-rake'
  gem 'rubocop-sequel'
  gem 'ruby-lsp'
end
