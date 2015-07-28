require File.expand_path('../config/environment', __FILE__)

use Chat::Socket
run Chat::App
