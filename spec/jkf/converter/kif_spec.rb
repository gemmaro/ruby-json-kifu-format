require 'spec_helper'

describe Jkf::Converter::Kif do
  let(:kif_converter) { Jkf::Converter::Kif.new }
  let(:kif_parser) { Jkf::Parser::Kif.new }

  subject { kif_parser.parse(kif_converter.convert(jkf)) }

  shared_examples(:parse_file) do |filename|
    let(:str) do
      if File.extname(filename) == '.kif'
        File.read(filename, encoding: 'Shift_JIS').toutf8
      else
        File.read(filename).toutf8
      end
    end
    let(:jkf) { kif_parser.parse(str).to_json }

    it "should be parse #{File.basename(filename)}" do
      is_expected.to eq JSON.parse(jkf)
    end
  end

  fixtures(:kif).each do |fixture|
    it_behaves_like :parse_file, fixture
  end

  describe 'handicap' do
    subject do
      <<~KIF
        手合割：十枚落ち
        手数----指手---------消費時間--
           1 投了#{'         '}
        まで0手で後手の勝ち
      KIF
    end

    let(:handicap_hash) do
      {
        'header' => { '手合割' => '十枚落ち' },
        'moves' => [{}, { 'special' => 'TORYO' }],
        'initial' => { 'preset' => '10' }
      }
    end

    it 'should be convert' do
      is_expected.to eq kif_converter.convert(handicap_hash)
    end
  end
end
