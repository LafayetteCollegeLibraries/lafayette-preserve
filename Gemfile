source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Sufia

# Please see https://github.com/projecthydra/sufia/issues/2323#issuecomment-230831332
gem 'active_fedora-noid', :git => 'https://github.com/projecthydra-labs/active_fedora-noid.git', ref: '8107a47121919ab250784b22e6ee7b066fa711db'

# gem 'sufia', '7.0.0.beta3'
# Mark Bussey (on June 30th) reported failures for creating CurationConcerns Work Models using the sufia:work generator
# Please see https://project-hydra.slack.com/archives/dev/p1467317470002834
# gem "sufia", "7.0.0.beta4", :git => "https://github.com/projecthydra/sufia.git", :ref => '786246a3c8adfab6607227b354d9e1c47bc80efd'
gem "sufia", "7.0.0"

gem 'hydra-role-management'
gem 'rack-cors', :require => 'rack/cors'
gem 'triplestore-adapter', :git => "https://github.com/osulp/triplestore-adapter", :branch => "0.1.0"
gem 'rdf-blazegraph'
gem 'rsolr', '~> 1.0'
gem 'blacklight_range_limit', '~> 6.0'
gem 'thor', '~> 0.19'

gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'mida'
gem 'config'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # gem 'pry-byebug'

  gem 'solr_wrapper', '>= 0.16.0'
  gem 'fcrepo_wrapper'

  gem 'engine_cart', '~> 1.0'
  gem 'rubocop-rspec', '~> 1.5'
  gem 'factory_girl'

  gem 'coveralls'
  gem 'rspec-rails'
  gem 'rspec-its', '~> 1.1'
  gem 'rspec-activemodel-mocks', '~> 1.0'
  gem "capybara", '~> 2.4'
  gem "poltergeist", "~> 1.5"
  gem 'database_cleaner', '~> 1.3'
  gem "equivalent-xml", '~> 0.5'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'rails-controller-testing', '~> 0'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
