$LOAD_PATH << File.expand_path("../lib")

# Set $ENABLE_NETWORK environment parameter to 1 to enable network operations..
ENABLE_NETWORK_OPERATIONS = (ENV["ENABLE_NETWORK"] && ENV["ENABLE_NETWORK"] != "0")

require 'sire_agenda'
