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

  context '#flush?' do
    it 'should return true if all suits are the same' do
      cards = (2..6).map { |num| Card.new("#{num}C") }
      expect(described_class.new(cards).flush?).to eq(true)
    end

    it 'should return false if one suit is different' do
      cards = %w[3H 4H 5H 6H 7C].map { |card| Card.new(card) }
      expect(described_class.new(cards).flush?).to eq(false)
    end
  end

  context '#straight?' do
    it 'should return true if all cards are sequential' do
      cards = %w[8C 9C QS JD TD].map { |card| Card.new(card) }
      expect(described_class.new(cards).straight?).to eq(true)
    end

    it 'should account for Ace being low' do
      cards = %w[4C AH 2H 3D 5S].map { |card| Card.new(card) }
      expect(described_class.new(cards).straight?).to eq(true)
    end

    it 'should return false if any card is out of sequence' do
      cards = %w[4C 8D 2H 3D 5S].map { |card| Card.new(card) }
      expect(described_class.new(cards).straight?).to eq(false)
    end
  end
end