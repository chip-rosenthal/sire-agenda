$LOAD_PATH << File.expand_path("../lib")

# Set $ENABLE_NETWORK environment parameter to 1 to enable network operations..
ENABLE_NETWORK_OPERATIONS = (ENV["ENABLE_NETWORK"] && ENV["ENABLE_NETWORK"] != "0")

require 'sire_agenda'

require 'rspec/expectations'

RSpec::Matchers.define :be_array_of do |expected|
  match do |actual|
    k = actual.map {|a| a.class}.sort.uniq
    case k.length
    when 0
      true
    when 1
      k.first == expected
    else
      false
    end
  end
end

