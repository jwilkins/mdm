require 'fileutils'

class MDM::Server < Sinatra::Base
  configure :development do
    LOGGER = Logger.new("#{MDM_DIR}/log/development.log")
    LOGGER.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime("%Y%m%d %H:%M:%S")}:#{progname}:#{severity}: #{msg}\n"
    end
    enable :logging, :dump_errors
    set :raise_errors, true
  end

  configure :test do
    LOGGER = Logger.new("#{MDM_DIR}/log/test.log")
    LOGGER.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime("%Y%m%d %H:%M:%S")}:#{progname}:#{severity}: #{msg}\n"
    end
    enable :logging, :dump_errors
    set :raise_errors, true
  end

  configure :production do
    LOGGER = Logger.new("#{MDM_DIR}/log/production.log")
    LOGGER.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime("%Y%m%d %H:%M:%S")}:#{progname}:#{severity}: #{msg}\n"
    end
    enable :logging, :dump_errors
    set :raise_errors, true
  end

  helpers do
    def logger
      LOGGER
    end
  end

  def req_plist(request)
    plist = nil
    begin
      body = request.body.read
      logger.info body
      plist = Plist.parse_xml(body)
    rescue => e
    end

    return plist
  end

  #$ curl -kD - -X PUT https://localhost:8443/mdm_checkin
  put '/mdm_checkin' do
    begin
      plist = req_plist(request)
      unless plist.keys.include?("MessageType")
        logger.error "No MessageType, WTF?" 
        halt 404, "No MessageType"
      end

      unless plist.keys.include?("UDID")
        logger.error "No UDID, WTF?" 
        halt 404, "No UDID"
      end


      case plist['MessageType']
      when 'Authenticate'
        return {}.to_plist
      when 'TokenUpdate'
        dev_info = {}
        %w(PushMagic Token UnlockToken).each { |pk|
          if plist.keys.include?(pk)
            if plist[pk].class == String
              dev_info[pk] = plist[pk]
            elsif plist[pk].class == StringIO
              dev_info[pk] = Base64.encode64(plist[pk].read)
            end
          end
        }
        dev_file = "#{File.join(MDM_DIR, "devices", plist['UDID'])}.device"
        open(dev_file, 'wb+') { |df| df << dev_info.to_yaml }
        return {}.to_plist
      end
    rescue => e
      logger.error "checkin error: #{e}"
      halt 404, "Invalid request"
    end
    {}.to_plist
  end

  put '/mdm_server' do
    begin
      plist = req_plist(request)
      dev_dir = "#{File.join(MDM_DIR, "devices", plist['UDID'])}"
      FileUtils.mkdir_p(dev_dir)

      # XXX: UDID should have checked in

      case plist['Status']
      when 'Idle'
        mm = MDM::Messages.new
        mm_di = mm.device_information
        cmd_uuid = mm_di['CommandUUID']
        # XXX: link CommandUUID to Device UDID
        # cmd_uuid = plist['UDID']
        return mm_di.to_plist
      when 'Acknowledged'
        di_file = "#{File.join(MDM_DIR, "devices", plist['UDID'], plist['CommandUUID'])}"
        open(di_file, 'wb+') { |df| df << plist.to_yaml }
        logger.info plist
      when 'CommandFormatError'
        logger.info plist
      end

    rescue => e
      halt 404, "Invalid request"
    end
    {}.to_plist
  end

  get '/push' do
    results = []
    Dir["#{MDM_DIR}/devices/*.device"].each { |dfn|
      begin
        logger.info "[d] opening #{dfn}"
        dev_info = YAML.load_file(dfn)
        pem = "#{File.join(MDM_DIR, 'certs', 'apns-push.pem')}"
        tok = dev_info['Token']
        pm = dev_info['PushMagic']

        ApplePush.send_notification(pem, tok, :other => { :mdm => pm })
        results << File.basename(dfn)
      rescue => e
        logger.error "[x] error: #{e}"
      end
    }
    "[*] sent notifications to #{results.length} devices (#{results.join(', ')})"
  end

  get '/ca' do
    if File.exist?("#{MDM_DIR}/certs/ca.crt")
      headers \
        "Content-Type"   => 'application/octet-stream;charset=utf-8',
        "Content-Disposition" => 'attachment;filename="ca.crt"'
      return open("#{MDM_DIR}/certs/ca.crt", "rb").read()
    else
      return "no ca certificate available"
    end
  end
end
