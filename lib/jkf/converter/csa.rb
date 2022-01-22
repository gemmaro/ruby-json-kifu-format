# frozen_string_literal: true

module Jkf
  module Converter
    # CSA v2.2 Converter
    class Csa < Base
      VERSION = '2.2'

      protected

      def convert_root(jkf)
        result = version
        result += convert_information(jkf['header']) if jkf['header']
        result += convert_initial(jkf['initial']) if jkf['initial']
        result += convert_moves(jkf['moves']) if jkf['moves']
        result
      end

      def convert_information(header)
        result = ''
        result += "N+#{header.delete('先手') || header.delete('下手') || ''}\n" if header['先手'] || header['下手']
        result += "N-#{header.delete('後手') || header.delete('上手') || ''}\n" if header['後手'] || header['上手']
        header.each { |(k, v)| result += "$#{csa_header_key(k)}:#{v}\n" }
        result
      end

      def convert_initial(initial)
        result = ''
        data = initial['data'] || {}
        result += if initial['preset'] == 'OTHER'
                    convert_board(data['board'])
                  else
                    convert_preset(initial['preset'])
                  end
        # 持駒
        if data['hands']
          result += convert_hands(data['hands'], 0)
          result += convert_hands(data['hands'], 1)
        end
        result += "#{csa_color(data['color'])}\n" if data['color']
        result
      end

      def convert_hands(hands, color)
        result = ''
        sum = 0
        hands[color].each_value { |n| sum += n }
        if sum.positive?
          result += "P#{csa_color(color)}"
          hands[color].to_a.reverse_each { |(k, v)| v.times { result += "00#{k}" } }
          result += "\n"
        end
        result
      end

      def convert_moves(moves)
        result = ''
        before_pos = nil
        moves.each do |move|
          next if move == {}

          result += convert_move(move['move'], before_pos) if move['move']
          result += convert_special(move['special'], move['color']) if move['special']
          if move['time']
            result += ",#{convert_time(move['time'])}"
          elsif move['move'] || move['special']
            result += "\n"
          end
          result += convert_comments(move['comments']) if move['comments']
          before_pos = move['move']['to'] if move['move'] && move['move']['to']
        end
        result
      end

      def convert_move(move, before_pos)
        result = csa_color(move['color'])
        result += move['from'] ? pos2str(move['from']) : '00'
        result += if move['to']
                    pos2str(move['to']) + move['piece']
                  else
                    pos2str(before_pos) + move['piece']
                  end
        result
      end

      def convert_special(special, color = nil)
        result = '%'
        result += csa_color(color) if color
        result + special
      end

      def convert_time(time)
        sec = (time['now']['m'] * 60) + time['now']['s']
        "T#{sec}\n"
      end

      # 文字列の配列を改行文字を挟みつつ1つの文字列にします
      def convert_comments(comments)
        comments.map { "'#{_1}\n" }.join
      end

      def convert_board(board)
        result = ''
        9.times do |y|
          result += "P#{y + 1}"
          9.times do |x|
            piece = board[8 - x][y]
            result += if piece == {}
                        ' * '
                      else
                        csa_color(piece['color']) + piece['kind']
                      end
          end
          result += "\n"
        end
        result
      end

      PRESET_MAPPING = {
        # 平手
        'HIRATE' => '',
        # 香落ち
        'KY' => '11KY',
        # 右香落ち
        'KY_R' => '91KY',
        # 角落ち
        'KA' => '22KA',
        # 飛車落ち
        'HI' => '82HI',
        # 飛香落ち
        'HIKY' => '22HI11KY91KY',
        # 二枚落ち
        '2' => '82HI22KA',
        # 三枚落ち
        '3' => '82HI22KA91KY',
        # 四枚落ち
        '4' => '82HI22KA11KY91KY',
        # 五枚落ち
        '5' => '82HI22KA81KE11KY91KY',
        # 左五枚落ち
        '5_L' => '82HI22KA21KE11KY91KY',
        # 六枚落ち
        '6' => '82HI22KA21KE81KE11KY91KY',
        # 八枚落ち
        '8' => '82HI22KA31GI71GI21KE81KE11KY91KY',
        # 十枚落ち
        '10' => '82HI22KA41KI61KI31GI71GI21KE81KE11KY91KY'
      }.freeze

      # よく知られた初期局面を表す文字列を、CSA形式の局面表現に変換します
      def convert_preset(preset)
        csa_preset = PRESET_MAPPING[preset]

        "PI#{csa_preset}"
      end

      def csa_color(color)
        color.zero? ? '+' : '-'
      end

      def pos2str(pos)
        format('%<x>d%<y>d', x: pos['x'], y: pos['y'])
      end

      def version
        "V#{VERSION}\n"
      end

      def csa_header_key(key)
        {
          '棋戦' => 'EVENT',
          '場所' => 'SITE',
          '開始日時' => 'START_TIME',
          '終了日時' => 'END_TIME',
          '持ち時間' => 'TIME_LIMIT'
        }[key] || key
      end
    end
  end
end
