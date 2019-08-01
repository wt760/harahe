class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    head :bad_request unless client.validate_signature(body, signature)

    arr_que=["","場所は？","時間は？","ラーメン食べたい？","中華食べたい？","洋食食べたい？","和食食べたい？"]
    arr_yes=["検索","現在地を使う","現在時刻","ラーメン食べたい！","中華食べたい！","洋食食べたい！","和食食べたい！"]
    arr_noo=["検索","場所を指定する","時間を指定する","ラーメン食べたくない…","中華食べたくない…","洋食食べたくない…","和食食べたくない…"]

    (arr_que.size-1).times do |i|
      client.parse_events_from(body).each do |event|
        if event.class == Line::Bot::Event::Message
          if event.type == Line::Bot::Event::MessageType::Text
            if event["message"]["text"]==arr_yes[i]||event["message"]["text"]==arr_noo[i]

              message = {
                type: "template",
                altText: "this is a confirm template",
                template: {
                  type: "confirm",
                  #type: 'text',a
                  #text: event.message['text']
                  #text: event["message"]["text"]
                  text: arr_que[i+1],
                  actions: [
                    {
                      type: "message",
                      label: arr_yes[i+1],
                      text: arr_yes[i+1]
                    },
                    {
                      type: "message",
                      label: arr_noo[i+1],
                      text: arr_noo[i+1]
                    }
                  ]
                }
              }
              client.reply_message(event['replyToken'], message)
            end
          end
        end
      end
      head :ok
    end
  end

end
