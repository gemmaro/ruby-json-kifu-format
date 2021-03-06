# frozen_string_literal: true

module Jkf
  module Converter
    # KIF Converter
    class Kif < Base
      protected

      include Kifuable

      def convert_root(jkf)
        reset!
        setup_players!(jkf)

        result = ''
        result += convert_header(jkf['header'], jkf) if jkf['header']
        result += convert_initial(jkf['initial']) if jkf['initial']
        result += @header2.join
        result += "手数----指手---------消費時間--\n"
        result += convert_moves(jkf['moves'])
        unless @forks.empty?
          result += "\n"
          result += @forks.join("\n")
        end

        result
      end

      def convert_header(header, jkf)
        header.map do |(key, value)|
          result = "#{key}：#{value}\n"
          if key =~ /\A[先後上下]手\Z/
            if key =~ /[先下]/
              @header2.unshift result
            else
              @header2 << result
            end
            nil
          elsif key == '手合割' && jkf['initial'] && jkf['initial']['preset'] && value == preset2str(jkf['initial']['preset'])
            nil
          else
            result
          end
        end.compact.join
      end

      def convert_moves(moves, idx = 0)
        result = ''
        moves.each_with_index do |move, i|
          if move['special']
            result += convert_special_line(move, i + idx)
          else
            result += convert_move_line(move, i + idx) if move['move']
            result += convert_comments(move['comments']) if move['comments']
            @forks.unshift convert_forks(move['forks'], i + idx) if move['forks']
          end
        end
        result
      end

      def convert_move_line(move, index)
        result = format('%4d ', index)
        result += convert_move(move['move'])
        result += convert_time(move['time']) if move['time']
        result += '+' if move['forks']
        "#{result}\n"
      end

      def convert_special_line(move, index)
        result = format('%4d ', index)
        result += ljust(special2kan(move['special']), 13)
        result += convert_time(move['time']) if move['time']
        result += '+' if move['forks']
        result += "\n"
        # first_board+speical分を引く(-2)
        result + convert_special(move['special'], index - 2)
      end

      def convert_move(move)
        result = convert_piece_with_pos(move)
        result += if move['from']
                    "(#{pos2str(move['from'])})"
                  else
                    '打'
                  end
        ljust(result, 13)
      end

      def convert_time(time)
        format(
          '(%<now_minute>2d:%<now_second>02d/%<total_hour>02d:%<total_minute>02d:%<total_second>02d)',
          now_minute: time['now']['m'],
          now_second: time['now']['s'],
          total_hour: time['total']['h'],
          total_minute: time['total']['m'],
          total_second: time['total']['s']
        )
      end

      SPECIAL_MOVE_MAPPING = {
        'CHUDAN' => '中断',
        'TORYO' => '投了',
        'JISHOGI' => '持将棋',
        'SENNICHITE' => '千日手',
        'TSUMI' => '詰み',
        'FUZUMI' => '不詰',
        'TIME_UP' => '切れ負け',
        'ILLEGAL_ACTION' => '反則勝ち',
        'ILLEGAL_MOVE' => '反則負け'
      }.freeze

      def special2kan(special)
        SPECIAL_MOVE_MAPPING[special]
      end

      # {https://docs.ruby-lang.org/en/master/String.html#method-i-ljust +String#ljust+}とは異なり、全角文字は幅が2として扱われます。
      def ljust(str, padded_width)
        len = 0
        str.each_codepoint { |codepoint| len += codepoint > 255 ? 2 : 1 }
        str + (' ' * (padded_width - len))
      end

      def pos2str(pos)
        format('%<x>d%<y>d', x: pos['x'], y: pos['y'])
      end
    end
  end
end
