source :rubygems

gem 'sinatra', :require => "sinatra/base"
gem 'plist'
gem 'rack'
gem 'apple-push'
gem 'uuid'

group :development do
  if RUBY_VERSION =~ /^1.9/
    gem "ruby-debug19", :require => "ruby-debug"
  else
    gem 'ruby-debug'
  end
end

group :test do
  gem "rspec"
  gem "rake"
end
