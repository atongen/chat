require 'dotenv'
Dotenv.load

lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chat'
