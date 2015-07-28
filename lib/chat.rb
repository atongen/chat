require 'sequel'

require 'chat/version'
require 'chat/config'

module Chat
  DB = ::Sequel.connect(Config.database_url)
end

require 'chat/model/user'
require 'chat/model/room'
require 'chat/model/room_message'
require 'chat/model/user_message'

require 'chat/app'
require 'chat/socket'
