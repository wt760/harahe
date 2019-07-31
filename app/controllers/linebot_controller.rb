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


    #arr=["オハヨー","おやすみ","うるせー","こんにちは","こんにちま","こんちは"]

    client.parse_events_from(body).each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: "template",
            altText: "this is a confirm template",
            template: {
              type: "confirm",
              #type: 'text',
              #text: arr[rand(arr.size)]
              #text: event.message['text']
              #text: event["message"]["text"]
              text: "ラーメン食べたい？",
              actions: [
                {
                  type: "message",
                  label: "はい",
                  text: "ラーメン食べたい"
                },
                {
                  type: "message",
                  label: "いいえ",
                  text: "ラーメン食べたくない"
                }
              ]
            }
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    end
    head :ok
  end

end
