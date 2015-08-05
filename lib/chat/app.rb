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

    get '/' do
      @websocket_uri = websocket_uri(current_user)
      erb :"index.html"
    end

    get '/rooms' do
      content_type :json
      Model::Room.order(:id).all.to_json
    end

    post '/rooms' do
      content_type :json

      data = JSON.parse(request.body.read)
      room = Model::Room.new(data)
      room.created_at = Time.now
      if room.save
        status 201
        room.to_json
      else
        status 400
        room.errors.to_json
      end
    end

    get '/rooms/:id' do |id|
      content_type :json

      room = Model::Room[id]
      room_messages = room.room_messages_dataset.eager(:user).reverse_order.map do |msg|
        values = msg.values
        values[:user] = msg.user
        values
      end

      room_user = Model::RoomUser.find_or_create(user_id: current_user.id, room_id: room.id) do |ru|
        ru.created_at = Time.now
      end

      { room: room,
        room_messages: room_messages,
        room_user: room_user
      }.to_json
    end

    get '/users' do
      content_type :json
      Model::User.order(:name).all.to_json
    end

    get '/users/:id' do |id|
      content_type :json

      user1_id, user2_id = [current_user.id, id.to_i].sort

      conversation = Model::Conversation.find_or_create(user1_id: user1_id, user2_id: user2_id) do |c|
        c.created_at = Time.now
      end

      if conversation.user1_id == current_user.id
        other = conversation.user2
      else
        other = conversation.user1
      end

      conversation_messages = conversation.conversation_messages_dataset.reverse_order.all

      { conversation: conversation,
        conversation_messages: conversation_messages,
        other: other
      }.to_json
    end

  end
end
