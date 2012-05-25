class MDM::Device
  def initialize(options={})
    @udid = options[:udid]
    @push_magic = options[:push_magic]
    @token = options[:token]
    @wipe_token = options[:wipe_token]
  end

  def save()

  end

  def self.get_device(udid)

  end
end
