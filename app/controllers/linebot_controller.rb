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

          when /.*(岡田|おかだ|okada|オカダ).*/
            push = "プログラマー\n岡田 雄輔"

          when /.*(後藤|ごとう|goto|ゴトウ).*/
            push ="WEB制作部長\n後藤 真之介"

          when /.*(須田|すだ|suda|スダ).*/
            push ="プロジェクトマネージャー\n須田 翔太"

          when /.*(前野|まえの|maeno|マエノ).*/
            push = "WEBマーケティング営業部長\n前野 薫"

          when /.*(さいとう|齋藤|斎藤|斉藤|saito|サイトウ).*/
            push ="PLUSIDEA PARTNERS\n代表取締役\n齋藤 翔太"

          when /.*(小島|こじま|kozima|kojima|コジマ).*/
            push ="プログラマー\n小島 拓也"

          when /.*(堤|つつみ|tutumi|ツツミ).*/
            push ="WEBマーケティング責任者\n堤 大地"

          when /.*(工藤|くどう|kudo|クドウ).*/
            push ="プログラマー・ライター\n工藤 照芳"

          when /.*(こいけ|小池|koike|コイケ).*/
            push ="PLUSIDEA\n代表取締役\n小池 隆太"

          else
            push ="弊社にそのような方はおりません。"

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
