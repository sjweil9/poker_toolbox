RSpec.describe PokerToolbox::Hand do
  Card = PokerToolbox::Card

  context '::from_json' do
    it 'should convert a JSON array into Card objects' do
      string = '["2C", "3H", "TD", "JH", "AS"]'
      expect(described_class.from_json(string).cards).to all(be_an_instance_of(Card))
    end
  end

  context '#initialize' do
    it 'should sort cards by rank' do
      cards = %w[3H TH JC KD AS].map { |string| Card.new(string) }
      expect(described_class.new(cards).cards.map(&:to_s)).to eq(%w[AS KD JC TH 3H])
    end
  end
end