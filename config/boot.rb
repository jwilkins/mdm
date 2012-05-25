ENV["RACK_ENV"] ||= "production"

require 'bundler'
Bundler.setup

Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require "./lib/mdm"
require "mdm/server"
