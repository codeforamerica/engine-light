source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolink
gem 'turbolinks'

gem 'pg'
# Released version is not compatible with rails 4, so have to pull from github :/
gem 'friendly_id', github: 'norman/friendly_id'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use unicorn as the app server
gem 'unicorn'

group :test do
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'fakeweb'
end

# Use debugger
# gem 'debugger', group: [:development, :test]

group :production do
  gem 'rails_12factor'
end