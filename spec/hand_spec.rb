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
    it 'should detect straight_flushes' do
      cards = %w[6H 7H 8H 9H TH]
      expect(hand_with(cards).hand_rank).to eq(:straight_flush)
    end

    it 'should detect four-of-a-kind' do
      cards = %w[4H 4C 4S 4D TC]
      expect(hand_with(cards).hand_rank).to eq(:four_of_a_kind)
    end

    it 'should detect full houses' do
      cards = %w[4H 4C 4S 3C 3D]
      expect(hand_with(cards).hand_rank).to eq(:full_house)
    end

    it 'should detect flushes' do
      cards = %w[4H 7H 9H JH AH]
      expect(hand_with(cards).hand_rank).to eq(:flush)
    end

    it 'should detect straights' do
      cards = %w[4H 5C 6S 7D 8H]
      expect(hand_with(cards).hand_rank).to eq(:straight)
    end

    it 'should detect three-of-a-kind' do
      cards = %w[9H 9C 9D 3H 7C]
      expect(hand_with(cards).hand_rank).to eq(:three_of_a_kind)
    end

    it 'should two pair' do
      cards = %w[4H 4C 7H 7D TS]
      expect(hand_with(cards).hand_rank).to eq(:two_pair)
    end

    it 'should detect pairs' do
      cards = %w[TC TD 3H 7S 8C]
      expect(hand_with(cards).hand_rank).to eq(:pair)
    end

    it 'should detect high card' do
      cards = %w[AC JD 3D 7C 6H]
      expect(hand_with(cards).hand_rank).to eq(:high_card)
    end
  end
end