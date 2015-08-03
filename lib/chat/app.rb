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

    helpers Sinatra::Cookies

    helpers do
      def websocket_uri(user)
        uris = Config.websocket_uris
        uri = uris[user.id % uris.length]
        "ws://#{uri.host}:#{uri.port}"
      end
    end

    before do
      if session[:user_id]
        @user = Model::User[session[:user_id]]
      else
        @user = Model::User.create(created_at: Time.now)
        session[:user_id] = @user.id
      end
    end

    get "/" do
      @rooms = Model::Room.all
      erb :"index.html"
    end

    get  %r{/room/([0-9a-z_]+)} do |n|
      @room = Model::Room.find_or_create(name: n) do |r|
        r.created_at = Time.now
      end
      @room_user = Model::RoomUser.find_or_create(user_id: @user.id, room_id: @room.id) do |ru|
        ru.created_at = Time.now
        ru.token = (0...40).map { ('a'..'z').to_a[rand(26)] }.join
      end
      erb :"room.html"
    end

    get "/assets/js/application.js" do
      @websocket_uri = websocket_uri(@user)
      content_type :js
      erb :"application.js"
    end

  end
end
