require 'sinatra/base'

module Chat
  class App < Sinatra::Base
    get "/" do
      erb :"index.html"
    end

    get "/room/:name" do |n|
      @name = n
      erb :"room.html"
    end

    get "/assets/js/application.js" do
      content_type :js
      erb :"application.js"
    end
  end
end