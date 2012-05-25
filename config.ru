require 'rubygems'
require 'bundler'

require 'webrick'
require 'webrick/https'
require 'net/http'
require 'openssl'


CERT_PATH = "#{File.join(File.dirname(__FILE__), '/certs')}"

webrick_options = {
  :Port               => 8443,
  :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
  #:DocumentRoot       => "/ruby/htdocs",
  :SSLEnable          => true,
  :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
  :SSLCertificate     => OpenSSL::X509::Certificate.new(File.open(File.join(CERT_PATH, "ufactory_org.crt")).read),
  :SSLPrivateKey      => OpenSSL::PKey::RSA.new(File.open(File.join(CERT_PATH, "ufactory.key")).read),
  :SSLCertName        => [ [ "CN", "ufactory.org"] ]
}

Bundler.require

require "#{File.dirname(__FILE__)}/lib/mdm"
require "mdm/server"

=begin
err_log = open("#{File.dirname(__FILE__)}/log/error.log", "a+")
$stderr.reopen(err_log)
log = open("#{File.dirname(__FILE__)}/log/server.log", "a+")
$stdout.reopen(log)
=end

Rack::Handler::WEBrick.run MDM::Server, webrick_options

