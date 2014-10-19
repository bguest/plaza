source 'https://rubygems.org'

# Specify your gem's dependencies in plaza.gemspec
gemspec

group :test do
  gem 'webmock',   '~> 1.18'  # HTTP stub/expectations
  gem 'simplecov', '~> 0.7.1' # Code Coverage
end

# Development gems that aren't run-time dependencies
group :development do
end

group :development, :test do
  gem 'guard-rspec'
  gem 'pry-nav', '~> 0.2.3' # Pry control flow
end
