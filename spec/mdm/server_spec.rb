require 'rubygems'
require 'bundler'
Bundler.require :test

require 'rack/test'
require 'sinatra'
require 'rspec'

set :environment, :test

require 'mdm'
require 'mdm/server'


describe MDM::Server do
  include Rack::Test::Methods

  def app
    @app ||= MDM::Server
  end

  it "handles checkins" do
    plist = open("#{MDM_DIR}/spec/client_authenticate.plist").read
    put '/mdm_checkin', plist
    last_response.should be_ok
    last_response.body.should =~ /plist/
  end
end
