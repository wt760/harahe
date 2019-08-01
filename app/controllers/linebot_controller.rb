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

    client.parse_events_from(body).each do |event|
      if event.class == Line::Bot::Event::Message
        if event.type == Line::Bot::Event::MessageType::Text
          if event["message"]["text"]=="検索"
            #質問０
            message = {
              "type": "template",
              "altText": "質問が追加されました",
              "template": {
                "type": "buttons",
                "text": "場所は？",
                "actions": [
                  {
                    "type": "postback",
                    "label": "この周辺",
                    "data": "0.0"
                  },
                  {
                    "type": "postback",
                    "label": "場所を指定する",
                    "data": "0.1"
                  },
                  {
                    "type": "postback",
                    "label": "スキップ",
                    "data": "0.2"
                  }
                ]
              }
            }
          end


        end
      end

      if event.class == Line::Bot::Event::Postback || event.class == Line::Bot::Event::Postback
        if event["postback"]["data"]=="0.0"
          #質問１
          message = {
            "type": "template",
            "altText": "質問が追加されました",
            "template": {
              "type": "buttons",
              "text": "何で向かう？",
              "actions": [
                {
                  "type": "postback",
                  "label": "徒歩",
                  "data": "1.0"
                },
                {
                  "type": "postback",
                  "label": "自転車",
                  "data": "1.1"
                },
                {
                  "type": "postback",
                  "label": "車",
                  "data": "1.2"
                }
              ]
            }
          }
        end

        if event["postback"]["data"]=="0.1"
          #質問２
          message = {
            "type": "template",
            "altText": "質問が追加されました",
            "template": {
              "type": "buttons",
              "text": "エリアを選んでね！",
              "actions": [
                {
                  "type": "postback",
                  "label": "吾妻・竹園",
                  "data": "2.0"
                },
                {
                  "type": "postback",
                  "label": "春日・天久保",
                  "data": "2.1"
                },
                {
                  "type": "postback",
                  "label": "天王台・桜",
                  "data": "2.2"
                },
                {
                  "type": "postback",
                  "label": "一の矢・花畑",
                  "data": "2.3"
                }
              ]
            }
          }
        end

        if event["postback"]["data"].to_f>=0.2 && event["postback"]["data"].to_f<3 #0.2, 1. ,2.の時
          #質問３
          message = {
            "type": "template",
            "altText": "質問が追加されました",
            "template": {
              "type": "buttons",
              "text": "時間は？",
              "actions": [
                {
                  "type": "postback",
                  "label": "現在時刻",
                  "data": "3.1"
                },
                {
                  "type": "postback",
                  "label": "時間を指定する",
                  "data": "3.0"
                },
                {
                  "type": "postback",
                  "label": "スキップ",
                  "data": "3.2"
                }
              ]
            }
          }
        end

        if event["postback"]["data"]=="3.0"
          #時間を入力
          message = {
            "type": "template",
            "altText": "質問が追加されました",
            "template": {
              "type": "buttons",
              "text": "時間を選択してね！",
              "actions": [
                {
                  "type":"datetimepicker",
                  "data":"3.3",
                  "mode":"datetime",
                  "label": "時間を選択",
                  "initial":"2019-12-25t00:00"
                }
              ]
            }
          }
        end

        if event["postback"]["data"].to_f>3 && event["postback"]["data"].to_f<4 #3.1-3.3

          if event["postback"]["data"]=="3.1"
            #データベースに現在日時をデータベースに入れる
          elsif event["postback"]["data"]=="3.3"
            #データベースに選択された日時をデータベースに入れる
          end
          #質問４
          message = {
            "type": "template",
            "altText": "質問が追加されました",
            "template": {
              "type": "buttons",
              "text": "ジャンルは？",
              "actions": [
                {
                  "type": "postback",
                  "label": "和食",
                  "data": "4.0"
                },
                {
                  "type": "postback",
                  "label": "洋食",
                  "data": "4.1"
                },
                {
                  "type": "postback",
                  "label": "中華",
                  "data": "4.2"
                },
                {
                  "type": "postback",
                  "label": "エスニック",
                  "data": "4.3"
                }
              ]
            }
          }
        end

        if event["postback"]["data"].to_f>=4 && event["postback"]["data"].to_f<5 #4.
          message={
            type: "text",
            text: "あなたにオススメのお店は..."
          }
        end

      end

      #binding.pry
      client.reply_message(event['replyToken'], message)

    end
    head :ok
  end

end

# if event["message"]["text"]==arr_yes[i]||event["message"]["text"]==arr_noo[i]
#
#   message = {
#     type: "template",
#     altText: "this is a confirm template",
#     template: {
#       type: "confirm",
#       #type: 'text',a
#       #text: event.message['text']
#       #text: event["message"]["text"]
#       text: arr_que[i+1],
#       actions: [
#         {
#           type: "message",
#           label: arr_yes[i+1],
#           text: arr_yes[i+1]
#         },
#         {
#           type: "message",
#           label: arr_noo[i+1],
#           text: arr_noo[i+1]
#         }
#       ]
#     }
#   }
#   client.reply_message(event['replyToken'], message)
# end
