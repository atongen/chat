require 'sinatra/base'
require 'sinatra/cookies'

require 'chat/websocket'

module Chat
  class App < Sinatra::Base
    set :root, File.expand_path('../../..', __FILE__)
    set :logging, true

    use Rack::Session::Cookie,
      key: 'chat.session',
      expire_after: 31536000, # one year
      secret: 'h@ckm3'

    use Chat::Websocket

    helpers do
      def websocket_uri(user)
        uris = Config.websocket_uris
        uri = uris[user.id % uris.length]
        "ws://#{uri.host}:#{uri.port}"
      end

      def current_user
        return @current_user if @current_user

        if session[:user_id]
          @current_user = Model::User[session[:user_id]]
        end

        unless @current_user
          @current_user = Model::User.create({
            name: "user_" + (0...4).map { ('0'..'9').to_a[rand(10)] }.join,
            token: (0...40).map { ('a'..'z').to_a[rand(26)] }.join,
            created_at: Time.now
          })
          session[:user_id] = @current_user.id
        end

        @current_user
      end
    end

    before { current_user }

    get "/" do
      @rooms = Model::Room.order(:id)
      @users = Model::User.order(:name).where(active: true)
      @conversations = Model::Conversation.where('user1_id = ? OR user2_id = ?', current_user.id, current_user.id).all

      erb :"index.html"
    end

    get  %r{/rooms/([0-9a-z_]+)} do |n|
      content_type :json

      room = Model::Room.find_or_create(name: n) do |r|
        r.created_at = Time.now
      end

      room_messages = room.room_messages

      room_user = Model::RoomUser.find_or_create(user_id: current_user.id, room_id: room.id) do |ru|
        ru.created_at = Time.now
      end

      { room: room,
        room_messages: room_messages,
        room_user: room_user
      }.to_json
    end

    get '/conversations/:user_id' do |user_id|
      content_type :json

      user1_id, user2_id = [current_user.id, user_id.to_i].sort

      conversation = Model::Conversation.find_or_create(user1_id: user1_id, user2_id: user2_id) do |c|
        c.created_at = Time.now
      end

      conversation_messages = conversation.conversation_messages

      { conversation: conversation,
        conversation_messages: conversation_messages
      }.to_json
    end

  end
end
