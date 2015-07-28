require './config/environment'

require 'chat'

use Chat::Socket
run Chat::App
