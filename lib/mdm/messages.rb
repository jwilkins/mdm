class MDM::Messages
  attr_accessor :messages

  def initialize
    messages = YAML.load_file(File.join(MDM_DIR, 'config', 'messages.yml'))
    @messages = {}
    messages.each { |mm|
      @messages[mm['RequestType']] = {'Command' => mm }
    }
  end
end
