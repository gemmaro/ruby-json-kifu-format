# frozen_string_literal: true

require 'kconv'
require_relative 'jkf/version'
require_relative 'jkf/parser'
require_relative 'jkf/converter'

# JSON Kifu Format
module Jkf
  # raise when unsupport file type
  class FileTypeError < StandardError; end

  # ファイルからパースします。
  #
  # 拡張子でフォーマットの判定をします。
  #
  # @param [String] file_name
  #
  # @return [String] KIF, KI2, CSA, JKF (JSON)
  def self.parse_file(file_name, encoding: Encoding::Shift_JIS)
    parser = case ::File.extname(file_name)
             when '.kif', '.kifu'
               ::Jkf::Parser::Kif.new
             when '.ki2', '.ki2u'
               ::Jkf::Parser::Ki2.new
             when '.csa'
               ::Jkf::Parser::Csa.new
             when '.jkf', '.json'
               JSON
             else
               raise FileTypeError
             end
    game_record_content = File.read(File.expand_path(file_name), encoding:).toutf8
    parser.parse(game_record_content)
  end

  # 文字列からパースします。
  #
  # 各パーサでパースに試みて、成功した場合に結果を返します。
  #
  # @param [String] game_record_content
  #
  # @return [Hash] JKF
  def self.parse(game_record_content)
    parsers = [::Jkf::Parser::Kif.new, ::Jkf::Parser::Ki2.new, ::Jkf::Parser::Csa.new, JSON]

    parsers.map do |parser|
      parser.parse(game_record_content)
    rescue StandardError
      nil
    end.compact.first || (raise FileTypeError)
  end
end
