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

    client.parse_events_from(body).each do |event|
      if event.class == Line::Bot::Event::Message
        if event.type == Line::Bot::Event::MessageType::Text
          if event["message"]["text"]=~/検索/
            #質問０
            message = {
              "type": "template",
              "altText": "質問に答えてね！",
              "template": {
                "type": "buttons",
                "text": "場所は？",
                "actions": [
                  {
                    "type": "postback",
                    "label": "地図から指定する",
                    "data": "0.0"
                  },
                  {
                    "type": "postback",
                    "label": "地域名を指定する",
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
          elsif event["message"]["text"]=="時刻"
            message={
              type: "text",
              text: Time.new
            }
          elsif event["message"]["text"]=="現在地"
            message={
              type: "text",
              text: "test"
            }
          else
            message={
              type: "text",
              text: "『検索』と送信すると筑波大学周辺の飲食店を絞り、優柔不断なあなたに最適なお店を提案します☺️"
            }
          end

        end

        if event.type == Line::Bot::Event::MessageType::Location
          #緯度経度をモデルに格納
          #text: event["message"]["latitude"]
          #text: event["message"]["longitude"]
          #で参照できる

          #質問１
          message = {
            "type": "template",
            "altText": "質問に答えてね！",
            "template": {
              "type": "buttons",
              "text": "何で向かう？",
              "actions": [
                {
                  "type": "postback",
                  "label": "徒歩(半径500m圏内を表示)",
                  "data": "1.0"
                },
                {
                  "type": "postback",
                  "label": "自転車(半径2km圏内を表示)",
                  "data": "1.1"
                },
                {
                  "type": "postback",
                  "label": "車(半径5km圏内を表示)",
                  "data": "1.2"
                }
              ]
            }
          }
        end

      end

      if event.class == Line::Bot::Event::Postback
        if event["postback"]["data"]=="0.0"
          #位置情報探す
          #0.3を返す
          message = {
            "type": "template",
            "altText": "質問に答えてね！",
            "template": {
              "type": "buttons",
              "text": "場所を選択する",
              "actions": [
                {
                  "type":"uri",
                  #"data":"0.3",
                  "label": "場所を指定してね！",
                  "uri": "line://nv/location"
                }
              ]
            }
          }
        end

        if event["postback"]["data"]=="0.1"
          #質問２
          message = {
            "type": "template",
            "altText": "質問に答えてね！",
            "template": {
              "type": "buttons",
              "text": "エリアを選んでね！",
              "actions": [
                {
                  "type": "postback",
                  "label": "吾妻・竹園周辺",
                  "data": "2.0"
                },
                {
                  "type": "postback",
                  "label": "春日・天久保周辺",
                  "data": "2.1"
                },
                {
                  "type": "postback",
                  "label": "天王台・桜周辺",
                  "data": "2.2"
                },
                {
                  "type": "postback",
                  "label": "一の矢・花畑周辺",
                  "data": "2.3"
                }
              ]
            }
          }
        end

        if event["postback"]["data"].to_f>=0.2 && event["postback"]["data"].to_f<3 #0.2, 1. ,2.の時
          #モデルに登録
          #ユーザIDは、event["source"]["userId"]
          if event["postback"]["data"].to_i==1
            #現在地取得
            #範囲取得
          elsif event["postback"]["data"].to_i==2
            #地域取得
          end

          #質問３
          message = {
            "type": "template",
            "altText": "質問に答えてね！",
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
            "altText": "質問に答えてね！",
            "template": {
              "type": "buttons",
              "text": "時間を選択してね！",
              "actions": [
                {
                  "type":"datetimepicker",
                  "data":"3.3",
                  "mode":"datetime",
                  "label": "時間を選択",
                  "initial":Time.now.strftime("%Y-%m-%dT%H:%M")
                }
              ]
            }
          }
        end

        if event["postback"]["data"].to_f>3 && event["postback"]["data"].to_f<4 #3.1-3.3

          if event["postback"]["data"]=="3.1"
            #データベースに現在日時をデータベースに入れる
            message={
              type:"text",
              text: Date.parse(Time.now.strftime("%Y-%m-%d")).wday
              #text: Date.parse(Time.now.strftime("%Y-%m-%dT%H:%M").split("T")[0]).wday
            }
          elsif event["postback"]["data"]=="3.3"
            #データベースに選択された日時をデータベースに入れる
            message={
              type:"text",
              #text: event["postback"]["params"]["datetime"]
              text: Date.parse(event["postback"]["params"]["datetime"].split("T")[0]).wday
            }
          end
          #質問４
          # message = {
          #   "type": "template",
          #   "altText": "質問に答えてね！",
          #   "template": {
          #     "type": "buttons",
          #     "text": "ジャンルは？",
          #     "actions": [
          #       {
          #         "type": "postback",
          #         "label": "和食",
          #         "data": "4.0"
          #       },
          #       {
          #         "type": "postback",
          #         "label": "洋食",
          #         "data": "4.1"
          #       },
          #       {
          #         "type": "postback",
          #         "label": "中華",
          #         "data": "4.2"
          #       },
          #       {
          #         "type": "postback",
          #         "label": "エスニック",
          #         "data": "4.3"
          #       }
          #     ]
          #   }
          # }
        end

        if event["postback"]["data"].to_i==4 #4.
          #ジャンルを絞る（中華はラーメンも含む）
          #質問５
          message = {
            "type": "template",
            "altText": "質問に答えてね！",
            "template": {
              "type": "buttons",
              "text": "やっぱラーメンがいいよな！？",
              "actions": [
                {
                  "type": "postback",
                  "label": "いいね！",
                  "data": "5.0"
                },
                {
                  "type": "postback",
                  "label": "それはちょっと…",
                  "data": "5.1"
                }
              ]
            }
          }
        end

        if event["postback"]["data"].to_i==5 #5.
          #ラーメンだけにするか。しないかをモデルに格納
          #検索結果
          message = {
            "type": "flex",
            "altText": "#",
            "contents": {
              "type": "bubble",
              "hero": {
                "type": "image",
                "url": "https://tblg.k-img.com/restaurant/images/Rvw/20748/640x640_rect_20748683.jpg",
                "size": "full",
                "aspectRatio": "20:13",
                "aspectMode": "cover",
                "action": {
                  "type": "uri",
                  "uri": "https://classmethod.jp/"
                }
              },
              "body": {
                "type": "box",
                "layout": "vertical",
                "spacing": "md",
                "action": {
                  "type": "uri",
                  "uri": "https://classmethod.jp/"
                },
                "contents": [
                  {
                    "type": "text",
                    "text": "清六屋",
                    "size": "xl",
                    "weight": "bold"
                  },
                  {
                    "type": "box",
                    "layout": "baseline",
                    "spacing": "sm",
                    "contents": [
                      {
                        "type": "text",
                        "text": "Place",
                        "color": "#aaaaaa",
                        "size": "sm",
                        "flex": 1
                      },
                      {
                        "type": "text",
                        "text": "茨城県つくば市天久保3丁目4-8",
                        "wrap": true,
                        "color": "#666666",
                        "size": "sm",
                        "flex": 5
                      }
                    ]
                  },
                  {
                    "type": "box",
                    "layout": "baseline",
                    "spacing": "sm",
                    "contents": [
                      {
                        "type": "text",
                        "text": "営業時間",
                        "color": "#aaaaaa",
                        "size": "sm",
                        "flex": 1
                      },
                      {
                        "type": "text",
                        "text": "10:00-18:00",
                        "wrap": true,
                        "color": "#666666",
                        "size": "sm",
                        "flex": 5
                      }
                    ]
                  }
                ]
              }
            }
          }
        end

      end

      #binding.pry
      client.reply_message(event['replyToken'], message)

    end
    head :ok
  end

end
