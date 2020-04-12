# frozen_string_literal: true

RSpec.describe PokerToolbox::Card do
  let(:ace) { described_class.new('AC') }
  let(:king) { described_class.new('KC') }
  let(:queen) { described_class.new('QC') }
  let(:jack) { described_class.new('JC') }
  let(:ten) { described_class.new('TC') }

  context '#value' do
    it 'should give numeric values for face cards' do
      expect(ace.value).to eq(14)
      expect(king.value).to eq(13)
      expect(queen.value).to eq(12)
      expect(jack.value).to eq(11)
      expect(ten.value).to eq(10)
    end

    it 'should return numeric values for numbered cards' do
      (2..9).each do |num|
        expect(described_class.new("#{num}C").value).to eq(num)
      end
    end
  end

  context '#to_s' do
    it 'should return the string value for face cards' do
      expect(ace.to_s).to eq('AC')
      expect(king.to_s).to eq('KC')
      expect(queen.to_s).to eq('QC')
      expect(jack.to_s).to eq('JC')
      expect(ten.to_s).to eq('TC')
    end

    it 'should return the string value for numbered cards' do
      (1..9).each do |num|
        expect(described_class.new("#{num}C").to_s).to eq("#{num}C")
      end
    end
  end
end