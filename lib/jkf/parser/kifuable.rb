# frozen_string_literal: true

module Jkf
  module Parser
    # Intersection of KIF and KI2
    module Kifuable
      protected

      # initialboard : (" " nonls nl)? ("+" nonls nl)? ikkatsuline+ ("+" nonls nl)?
      def parse_initialboard
        s0 = s1 = @current_pos
        if match_space == :failed
          @current_pos = s1
        else
          parse_nonls
          s2 = parse_nl
          @current_pos = s1 if s2 == :failed
        end
        s2 = @current_pos
        if match_str('+') == :failed
          @current_pos = s2
        else
          parse_nonls
          @current_pos = s2 if parse_nl == :failed
        end
        s4 = parse_ikkatsuline
        if s4 == :failed
          s3 = :failed
        else
          s3 = []
          while s4 != :failed
            s3 << s4
            s4 = parse_ikkatsuline
          end
        end
        if s3 == :failed
          @current_pos = s0
          :failed
        else
          s4 = @current_pos
          if match_str('+') == :failed
            @current_pos = s4
          else
            parse_nonls
            @current_pos = s4 if parse_nl == :failed
          end
          @reported_pos = s0
          transform_initialboard(s3)
        end
      end

      # ikkatsuline : "|" masu:masu+ "|" nonls! nl
      def parse_ikkatsuline
        s0 = @current_pos
        if match_str('|') == :failed
          @current_pos = s0
          s0 = :failed
        else
          s3 = parse_masu
          if s3 == :failed
            s2 = :failed
          else
            s2 = []
            while s3 != :failed
              s2 << s3
              s3 = parse_masu
            end
          end
          if (s2 != :failed) && match_str('|') != :failed
            s4 = parse_nonls!
            if (s4 != :failed) && parse_nl != :failed
              @reported_pos = s0
              s0 = s2
            else
              @current_pos = s0
              s0 = :failed
            end
          else
            @current_pos = s0
            s0 = :failed
          end
        end

        s0
      end

      # masu : teban piece | " ???"
      def parse_masu
        s0 = @current_pos
        s1 = parse_teban
        if s1 == :failed
          @current_pos = s0
          s0 = :failed
        else
          s2 = parse_piece
          if s2 == :failed
            @current_pos = s0
            s0 = :failed
          else
            @reported_pos = s0
            s0 = { 'color' => s1, 'kind' => s2 }
          end
        end
        if s0 == :failed
          s0 = @current_pos
          s1 = match_str(' ???')
          if s1 != :failed
            @reported_pos = s0
            s1 = {}
          end
          s0 = s1
        end

        s0
      end

      # teban : (" " | "+" | "^") | ("v" | "V")
      def parse_teban
        s0 = @current_pos
        s1 = match_space
        if s1 == :failed
          s1 = match_str('+')
          s1 = match_str('^') if s1 == :failed
        end
        if s1 != :failed
          @reported_pos = s0
          s1 = 0
        end
        s0 = s1
        if s0 == :failed
          s0 = @current_pos
          s1 = match_str('v')
          s1 = match_str('V') if s1 == :failed
          if s1 != :failed
            @reported_pos = s0
            s1 = 1
          end
          s0 = s1
        end
        s0
      end

      # pointer : "&" nonls nl
      def parse_pointer
        s0 = @current_pos
        s1 = match_str('&')
        if s1 == :failed
          @current_pos = s0
          s0 = :failed
        else
          s2 = parse_nonls
          s3 = parse_nl
          if s3 == :failed
            @current_pos = s0
            s0 = :failed
          else
            s0 = [s1, s2, s3]
          end
        end
        s0
      end

      # num : [???????????????????????????]
      def parse_num
        s0 = @current_pos
        s1 = match_regexp(/^[???????????????????????????]/)
        if s1 != :failed
          @reported_pos = s0
          s1 = zen2n(s1)
        end
        s1
      end

      # numkan : [???????????????????????????]
      def parse_numkan
        s0 = @current_pos
        s1 = match_regexp(/^[???????????????????????????]/)
        if s1 != :failed
          @reported_pos = s0
          s1 = kan2n(s1)
        end
        s1
      end

      # piece : "???"? [????????????????????????????????????????????????]
      def parse_piece
        s0 = @current_pos
        s1 = match_str('???')
        s1 = '' if s1 == :failed
        s2 = match_regexp(/^[????????????????????????????????????????????????]/)
        if s2 == :failed
          @current_pos = s0
          :failed
        else
          @reported_pos = s0
          kind2csa(s1 + s2)
        end
      end

      # result : "??????" [0-9]+ "???" (
      #            "???" (turn "??????" (result_toryo | result_illegal)) |
      #            result_timeup | result_chudan | result_jishogi |
      #            result_sennichite | result_tsumi | result_fuzumi
      #          ) nl
      def parse_result
        s0 = @current_pos
        if match_str('??????') == :failed
          @current_pos = s0
          :failed
        else
          s2 = match_digits!
          if (s2 != :failed) && match_str('???') != :failed
            s4 = @current_pos
            if (match_str('???') != :failed) && parse_turn != :failed
              if match_str('??????') == :failed
                @current_pos = s4
                s4 = :failed
              else
                s8 = parse_result_toryo
                s8 = parse_result_illegal if s8 == :failed
                s4 = if s8 == :failed
                       @current_pos = s4
                       :failed
                     else
                       @reported_pos = s4
                       s8
                     end
              end
            else
              @current_pos = s4
              s4 = :failed
            end
            if s4 == :failed
              s4 = parse_result_timeup
              if s4 == :failed
                s4 = parse_result_chudan
                if s4 == :failed
                  s4 = parse_result_jishogi
                  if s4 == :failed
                    s4 = parse_result_sennichite
                    if s4 == :failed
                      s4 = parse_result_tsumi
                      s4 = parse_result_fuzumi if s4 == :failed
                    end
                  end
                end
              end
            end
            if (s4 != :failed) && (parse_nl != :failed || eos?)
              @reported_pos = s0
              s4
            else
              @current_pos = s0
              :failed
            end
          else
            @current_pos = s0
            :failed
          end
        end
      end

      # result_toryo : "??????"
      def parse_result_toryo
        s0 = @current_pos
        s1 = match_str('??????')
        if s1 == :failed
          @current_pos = s0
          :failed
        else
          @reported_pos = s0
          'TORYO'
        end
      end

      # result_illegal : "??????" ("??????" | "??????")
      def parse_result_illegal
        s0 = @current_pos
        if match_str('??????') == :failed
          @current_pos = s0
          :failed
        else
          s10 = @current_pos
          s11 = match_str('??????')
          if s11 != :failed
            @reported_pos = s10
            s11 = 'ILLEGAL_ACTION'
          end
          s10 = s11
          if s10 == :failed
            s10 = @current_pos
            s11 = match_str('??????')
            if s11 != :failed
              @reported_pos = s10
              s11 = 'ILLEGAL_MOVE'
            end
            s10 = s11
          end
          if s10 == :failed
            @current_pos = s0
            :failed
          else
            @reported_pos = s0
            s10
          end
        end
      end

      # result_timeup : "????????????????????????" turn "????????????"
      def parse_result_timeup
        s0 = @current_pos
        if (match_str('????????????????????????') != :failed) && parse_turn != :failed
          if match_str('????????????') == :failed
            @current_pos = s0
            :failed
          else
            @reported_pos = s0
            'TIME_UP'
          end
        else
          @current_pos = s0
          :failed
        end
      end

      # result_chudan : "?????????"
      def parse_result_chudan
        s0 = @current_pos
        s1 = match_str('?????????')
        if s1 == :failed
          @current_pos = s0
          :failed
        else
          @reported_pos = s0
          'CHUDAN'
        end
      end

      # result_jishogi : "????????????"
      def parse_result_jishogi
        s0 = @current_pos
        s1 = match_str('????????????')
        if s1 == :failed
          @current_pos = s0
          :failed
        else
          @reported_pos = s0
          'JISHOGI'
        end
      end

      # result_sennichite : "????????????"
      def parse_result_sennichite
        s0 = @current_pos
        s1 = match_str('????????????')
        if s1 == :failed
          @current_pos = s0
          :failed
        else
          @reported_pos = s0
          'SENNICHITE'
        end
      end

      # result_tsumi : "???"? "???" "???"?
      def parse_result_tsumi
        s0 = @current_pos
        match_str('???')
        if match_str('???') == :failed
          @current_pos = s0
          :failed
        else
          match_str('???')
          @reported_pos = s0
          'TSUMI'
        end
      end

      # result_fuzumi : "?????????"
      def parse_result_fuzumi
        s0 = @current_pos
        s1 = match_str('?????????')
        if s1 == :failed
          @current_pos = s0
          :failed
        else
          @reported_pos = s0
          'FUZUMI'
        end
      end

      # skipline : "#" nonls newline
      def parse_skipline
        s0 = @current_pos
        s1 = match_str('#')
        if s1 == :failed
          @current_pos = s0
          s0 = :failed
        else
          s2 = parse_nonls
          s3 = parse_newline
          s0 = if s3 == :failed
                 @current_pos = s0
                 :failed
               else
                 [s1, s2, s3]
               end
        end
        s0
      end

      # whitespace : " " | "\t"
      def parse_whitespace
        match_regexp(/^[ \t]/)
      end

      # newline : whitespace* ("\n" | "\r" "\n"?)
      def parse_newline
        s0 = @current_pos
        s1 = []
        s2 = parse_whitespace
        while s2 != :failed
          s1 << s2
          s2 = parse_whitespace
        end
        s2 = match_str("\n")
        if s2 == :failed
          s2 = @current_pos
          s3 = match_str("\r")
          s2 = if s3 == :failed
                 @current_pos = s2
                 :failed
               else
                 s4 = match_str("\n")
                 s4 = nil if s4 == :failed
                 [s3, s4]
               end
        end
        if s2 == :failed
          @current_pos = s0
          :failed
        else
          [s1, s2]
        end
      end

      # nl : newline+ skipline*
      def parse_nl
        s0 = @current_pos
        s2 = parse_newline
        if s2 == :failed
          s1 = :failed
        else
          s1 = []
          while s2 != :failed
            s1 << s2
            s2 = parse_newline
          end
        end
        if s1 == :failed
          @current_pos = s0
          :failed
        else
          s2 = []
          s3 = parse_skipline
          while s3 != :failed
            s2 << s3
            s3 = parse_skipline
          end
          [s1, s2]
        end
      end

      # nonl :
      def parse_nonl
        match_regexp(/^[^\r\n]/)
      end

      # nonls : nonl*
      def parse_nonls
        stack = []
        matched = parse_nonl
        while matched != :failed
          stack << matched
          matched = parse_nonl
        end
        stack
      end

      # nonls! : nonl+
      def parse_nonls!
        matched = parse_nonls
        if matched.empty?
          :failed
        else
          matched
        end
      end

      # transform header-data to jkf
      def transform_root_header_data(ret)
        if ret['header']['??????']
          ret['initial']['data']['color'] = '??????'.include?(ret['header']['??????']) ? 0 : 1
          ret['header'].delete('??????')
        else
          ret['initial']['data']['color'] = 0
        end
        ret['initial']['data']['hands'] = [
          make_hand(ret['header']['???????????????'] || ret['header']['???????????????']),
          make_hand(ret['header']['???????????????'] || ret['header']['???????????????'])
        ]
        %w[??????????????? ??????????????? ??????????????? ???????????????].each do |key|
          ret['header'].delete(key)
        end
      end

      # transfrom forks to jkf
      def transform_root_forks(forks, moves)
        fork_stack = [{ 'te' => 0, 'moves' => moves }]
        forks.each do |f|
          now_fork = f
          fork = fork_stack.pop
          fork = fork_stack.pop while fork['te'] > now_fork['te']
          move = fork['moves'][now_fork['te'] - fork['te']]
          move['forks'] ||= []
          move['forks'] << now_fork['moves']
          fork_stack << fork
          fork_stack << now_fork
        end
      end

      # transform initialboard to jkf
      def transform_initialboard(lines)
        board = []
        9.times do |i|
          line = []
          9.times do |j|
            line << lines[j][8 - i]
          end
          board << line
        end
        { 'preset' => 'OTHER', 'data' => { 'board' => board } }
      end

      # zenkaku number to number
      def zen2n(full_width_digit)
        '??????????????????????????????'.index(full_width_digit)
      end

      # kanji number to number (1)
      def kan2n(kanji_digit)
        '??????????????????????????????'.index(kanji_digit)
      end

      # kanji number to number (2)
      def kan2n2(kanji_number_zero_to_ten)
        case kanji_number_zero_to_ten.length
        when 1
          '?????????????????????????????????'.index(kanji_number_zero_to_ten)
        when 2
          '?????????????????????????????????'.index(kanji_number_zero_to_ten[1]) + 10
        else
          raise '21??????????????????????????????????????????'
        end
      end

      # kanji piece-type to csa
      def kind2csa(kind)
        if kind[0] == '???'
          {
            '???' => 'NY',
            '???' => 'NK',
            '???' => 'NG'
          }[kind[1]]
        else
          {
            '???' => 'FU',
            '???' => 'KY',
            '???' => 'KE',
            '???' => 'GI',
            '???' => 'KI',
            '???' => 'KA',
            '???' => 'HI',
            '???' => 'OU',
            '???' => 'OU',
            '???' => 'TO',
            '???' => 'NY',
            '???' => 'NK',
            '???' => 'NG',
            '???' => 'UM',
            '???' => 'RY',
            '???' => 'RY'
          }[kind]
        end
      end

      # preset string to jkf
      def preset2str(preset)
        {
          '??????' => 'HIRATE',
          '?????????' => 'KY',
          '????????????' => 'KY_R',
          '?????????' => 'KA',
          '????????????' => 'HI',
          '????????????' => 'HIKY',
          '????????????' => '2',
          '????????????' => '3',
          '????????????' => '4',
          '????????????' => '5',
          '???????????????' => '5_L',
          '????????????' => '6',
          '????????????' => '8',
          '????????????' => '10',
          '?????????' => 'OTHER'
        }[preset.gsub(/\s/, '')]
      end
    end
  end
end
