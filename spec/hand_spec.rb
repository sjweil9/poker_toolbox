RSpec.describe PokerToolbox::Hand do
  Card = PokerToolbox::Card

  def hand_with(cards)
    described_class.new(cards.map { |card| Card.new(card) })
  end

  context '::from_json' do
    it 'should convert a JSON array into Card objects' do
      string = '["2C", "3H", "TD", "JH", "AS"]'
      expect(described_class.from_json(string).cards).to all(be_an_instance_of(Card))
    end
  end

  context '#initialize' do
    it 'should sort cards by rank' do
      cards = %w[3H TH JC KD AS]
      expect(hand_with(cards).cards.map(&:to_s)).to eq(%w[AS KD JC TH 3H])
    end
  end

  context '#flush?' do
    it 'should return true if all suits are the same' do
      cards = %w[2C 3C 4C 6C 7C]
      expect(hand_with(cards).flush?).to eq(true)
    end

    it 'should return false if one suit is different' do
      cards = %w[3H 4H 5H 6H 7C]
      expect(hand_with(cards).flush?).to eq(false)
    end
  end

  context '#straight?' do
    it 'should return true if all cards are sequential' do
      cards = %w[8C 9C QS JD TD]
      expect(hand_with(cards).straight?).to eq(true)
    end

    it 'should account for Ace being low' do
      cards = %w[4C AH 2H 3D 5S]
      expect(hand_with(cards).straight?).to eq(true)
    end

    it 'should return false if any card is out of sequence' do
      cards = %w[4C 8D 2H 3D 5S]
      expect(hand_with(cards).straight?).to eq(false)
    end
  end

  context '#hand_rank' do
    it 'should detect :straight_flushes' do
      cards = %w[6H 7H 8H 9H TH]
      expect(hand_with(cards).hand_rank).to eq(:straight_flush)
    end
  end
end