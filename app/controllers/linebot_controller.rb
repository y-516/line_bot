class LinebotController < ApplicationController
  require 'line/bot'
  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]
  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          # 正規表現で「〜』をパターンマッチしてkeywordへ格納
          # keyword = event.message['text'].match(/.*「(.+)」.*/)
          input = event.message['text']

          case input

          when /.*(岡田|おかだ).*/
            push = "君は岡田だね"

          when /.*(後藤|ごとう).*/
            push ="君は後藤だね"
          end


          message = {
            type: 'text',
            text: push
          }













          # keyword = event.message['text'].match(/.*岡田.*/)
          # マッチングしたときのみ入力されたキーワードを使用
          # if  keyword.present?
          #   seed2 = select_word
          #   message = [{
          #     type: 'text',
          #     text: "君は岡田だね"
          #   },{
          #     type: 'text',
          #     # keyword[1]：「」内の文言
          #     text: "#{keyword[1]} × #{seed2} !!"
          #   }]
          # マッチングしなかった場合は元々の仕様と同じようにキーワードを2つ選択して返す
          # else
          #   seed1 = select_word
          #   seed2 = select_word
          #   while seed1 == seed2
          #     seed2 = select_word
          #   end
          #   message = [{
          #     type: 'text',
          #     text: "キーワード何にしようかな"
          #   },{
          #     type: 'text',
          #     text: "#{seed1} × #{seed2} !!"
          #   }]
          # end
          client.reply_message(event['replyToken'], message)
        end
      end
    }
    head :ok
  end
  private
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
  def select_word
    # この中を変えると返ってくるキーワードが変わる
    seeds = ["アイデア１", "アイデア２", "アイデア３", "アイデア４"]
    seeds.sample
  end
end
