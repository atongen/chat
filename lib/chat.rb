require 'sequel'
require 'march_hare'
require 'celluloid/current'
require 'json'

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

Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :tactical_eager_loading

require 'chat/model/user'
require 'chat/model/room'
require 'chat/model/conversation'
require 'chat/model/room_user'
require 'chat/model/room_message'
require 'chat/model/conversation_message'

require 'chat/channel/user'
require 'chat/channel/room'

require 'chat/message_service'
require 'chat/message_store'
require 'chat/app'

at_exit do
  Chat::DB.disconnect
  Chat::RABBITMQ.close
end
