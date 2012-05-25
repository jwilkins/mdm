require 'bundler/setup'
require 'sinatra'
Sinatra::Application.environment = :test
Bundler.require :default, Sinatra::Application.environment
require 'rspec'
#require File.dirname(__FILE__) + '/../config/boot'

RSpec.configure do |config|
  config.before(:each) { }
end

