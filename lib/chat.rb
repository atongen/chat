require 'sequel'
require 'march_hare'

require 'chat/version'
require 'chat/config'

module Chat
  begin
    DB = ::Sequel.connect(Config.database_url)
  rescue => e
    puts "Unable to connect to db."
    raise e
  end

  begin
    RABBITMQ = ::MarchHare.connect(Config.rabbitmq_creds)
    RABBITMQ.start
  rescue => e
    puts "Unable to connect to rabbitmq."
    raise e
  end
end

require 'chat/model/user'
require 'chat/model/room'
require 'chat/model/room_user'
require 'chat/model/room_message'
require 'chat/model/user_message'

require 'chat/app'

at_exit do
  Chat::DB.disconnect
  Chat::RABBIT.close
end
