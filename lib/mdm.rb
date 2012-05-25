# encoding: UTF-8
$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'bundler'
require 'logger'
require 'yaml'
Bundler.require

MDM_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

class MDM
  class Settings < Settingslogic
    source "#{MDM_DIR}/config/application.yml"
    if %w(production test development).include?(ENV['RACK_ENV'])
      namespace ENV['RACK_ENV']
    else
      namespace 'production'
    end
    load!
  end
end

ApplePush.host = MDM::Settings.applepush.host
ApplePush.port = MDM::Settings.applepush.port

require 'mdm/device'
require 'mdm/inventory'
require 'mdm/messages'
