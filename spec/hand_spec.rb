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

  context '#value' do
    context 'for straight flushes' do
      it 'should be higher for the lowest straight flush than the highest four-of-a-kind' do
        sf = hand_with(%w[AC 2C 3C 4C 5C])
        four_of_a_kind = hand_with(%w[AH AD AS AC KD])
        expect(sf.value).to be > four_of_a_kind.value
      end

      it 'should break tie for the highest card in a straight flush' do
        king_high = hand_with(%w[9H TH JH QH KH])
        queen_high = hand_with(%w[8D 9D TD JD QD])
        expect(king_high.value).to be > queen_high.value
      end

      it 'should calculate ace value properly when used low' do
        ace_low = hand_with(%w[AC 2C 3C 4C 5C])
        six_high = hand_with(%w[2D 3D 4D 5D 6D])
        expect(six_high.value).to be > ace_low.value
      end

      it 'should calculate ace value properly when used high' do
        ace_high = hand_with(%w[TC JC QC KC AC])
        king_high = hand_with(%w[9D TD JD QD KD])
        expect(ace_high.value).to be > king_high.value
      end
    end

    context 'for four-of-a-kind' do
      it 'should be higher for the lowest four-of-a-kind than the highest full house' do
        four_of_a_kind = hand_with(%w[2C 2D 2H 2S 3C])
        full_house = hand_with(%w[AH AD AS KD KC])
        expect(four_of_a_kind.value).to be > full_house.value
      end

      it 'should break tie based on the highest four-of-a-kind' do
        four_aces = hand_with(%w[AD AH AC AS 2D])
        four_kings = hand_with(%w[KD KH KC KS QD])
        expect(four_aces.value).to be > four_kings.value
      end
    end

    context 'for full-houses' do
      it 'should be higher for the lowest full house than the highest flush' do
        full_house = hand_with(%w[2C 2H 2D 3C 3S])
        flush = hand_with(%w[AD KD QC JD TS])
        expect(full_house.value).to be > flush.value
      end

      it 'should break ties based on the set of three in the full house' do
        three_kings = hand_with(%w[KD KQ KC 2C 2H])
        three_queens = hand_with(%w[QC QH QD AH AS])
        expect(three_kings.value).to be > three_queens.value
      end

      it 'should further break ties based on the set of two in the full house' do
        two_kings = hand_with(%w[2H 2C 2D KS KD])
        two_jacks = hand_with(%w[2H 2C 2D JH JD])
        expect(two_kings.value).to be > two_jacks.value
      end
    end

    context 'for flushes' do
      it 'should be higher for the lowest flush than the highest straight' do
        flush = hand_with(%w[AH 2H 3H 4H 5H])
        straight = hand_with(%w[TD JC QH KS AD])
        expect(flush.value).to be > straight.value
      end

      it 'should break ties based on the highest card in the flush' do
        king_high = hand_with(%w[2D 3D 4D 5D KD])
        queen_high = hand_with(%w[8H 9H JH QH 7H])
        expect(king_high.value).to be > queen_high.value
      end
    end

    context 'for straights' do
      it 'should be higher for the lowest straight than the highest three-of-a-kind' do
        straight = hand_with(%w[AC 2D 3H 4S 5C])
        three_of_a_kind = hand_with(%w[AD AS AH KC QH])
        expect(straight.value).to be > three_of_a_kind.value
      end

      it 'should break tie for the highest card in a straight' do
        king_high = hand_with(%w[9H TD JH QH KH])
        queen_high = hand_with(%w[8D 9D TC JD QD])
        expect(king_high.value).to be > queen_high.value
      end

      it 'should calculate ace value properly when used low' do
        ace_low = hand_with(%w[AC 2C 3D 4C 5C])
        six_high = hand_with(%w[2D 3D 4S 5D 6D])
        expect(six_high.value).to be > ace_low.value
      end

      it 'should calculate ace value properly when used high' do
        ace_high = hand_with(%w[TC JH QC KC AC])
        king_high = hand_with(%w[9D TD JS QD KD])
        expect(ace_high.value).to be > king_high.value
      end
    end

    context 'for three-of-a-kind' do
      it 'should be higher for the lowest three-of-a-kind than the highest two pair' do
        three_twos = hand_with(%w[2C 2D 2H 3C 4S])
        aces_and_kings = hand_with(%w[AC AD KH KS QD])
        expect(three_twos.value).to be > aces_and_kings.value
      end

      it 'should break tie based on high cards' do
        king_high = hand_with(%w[3C 3D 3S KS JD])
        queen_high = hand_with(%w[3C 3D 3S QD JC])
        expect(king_high.value).to be > queen_high.value

        king_queen_high = hand_with(%w[3C 3D 3S KS QH])
        king_jack_high = hand_with(%w[3C 3D 3S KS JH])
        expect(king_queen_high.value).to be > king_jack_high.value
      end
    end

    context 'for two-pair' do
      it 'should be higher for the lowest two pair than the highest single pair' do
        twos_and_threes = hand_with(%w[2C 2H 3S 3D 4H])
        aces = hand_with(%w[AH AD KC QH JS])
        expect(twos_and_threes.value).to be > aces.value
      end

      it 'should break ties based on the highest of the two pairs first' do
        aces_and_twos = hand_with(%w[AH AC 2C 2H 3S])
        kings_and_queens = hand_with(%w[KH KD QS QC AS])
        expect(aces_and_twos.value).to be > kings_and_queens.value
      end

      it 'should break ties based on the second pair next' do
        aces_and_kings = hand_with(%w[AH AC KD KS 2C])
        aces_and_queens = hand_with(%w[AD AS QC QH KC])
        expect(aces_and_kings.value).to be > aces_and_queens.value
      end

      it 'should break ties based on the high card finally' do
        queen_high = hand_with(%w[AH AC KD KS QC])
        jack_high = hand_with(%w[AS AD KH KC JC])
        expect(queen_high.value).to be > jack_high.value
      end
    end

    context 'for pairs' do
      it 'should be higher for the lowest pair than the highest high card' do
        twos = hand_with(%w[2C 2H 3S 4D 5H])
        ace_high = hand_with(%w[AH QC JD TS 9H])
        expect(twos.value).to be > ace_high.value
      end

      it 'should break ties based on the pair first' do
        jacks = hand_with(%w[JD JH 2C 3H 4S])
        tens = hand_with(%w[TH TS AC KD QC])
        expect(jacks.value).to be > tens.value
      end

      it 'should break ties based on high cards subsequently' do
        ace_high = hand_with(%w[TH TD AC 2H 3S])
        king_high = hand_with(%w[TS TC KD QH JC])
        expect(ace_high.value).to be > king_high.value

        ace_king_high = hand_with(%w[TH TD AC KD 2S])
        ace_queen_high = hand_with(%w[TS TC AD QS JC])
        expect(ace_king_high.value).to be > ace_queen_high.value

        ace_king_queen_high = hand_with(%w[TH TD AC KD QC])
        ace_king_jack_high = hand_with(%w[TS TC AC KD JS])
        expect(ace_king_queen_high.value).to be > ace_king_jack_high.value
      end
    end

    context 'high cards' do
      it 'should always break ties starting with high cards in order' do
        ace_high = hand_with(%w[AC 3H 4D 5S 6C])
        king_high = hand_with(%w[KD QH JC TS 8D])
        expect(ace_high.value).to be > king_high.value

        ace_king_high = hand_with(%w[AC KD 2C 3S 4H])
        ace_queen_high = hand_with(%w[AC QD JS TC 9H])
        expect(ace_king_high.value).to be > ace_queen_high.value

        ace_king_queen_high = hand_with(%w[AC KD QH 2S 3D])
        ace_king_jack_high = hand_with(%w[AC KD JH TC 9S])
        expect(ace_king_queen_high.value).to be > ace_king_jack_high.value

        ace_king_queen_jack_high = hand_with(%w[AC KD QS JD 2H])
        ace_king_queen_ten_high = hand_with(%w[AC KD QS TD 9H])
        expect(ace_king_queen_jack_high.value).to be > ace_king_queen_ten_high.value

        ace_king_queen_jack_nine_high = hand_with(%w[AC KD QS JD 9H])
        ace_king_queen_jack_eight_high = hand_with(%w[AC KD QS JD 8H])
        expect(ace_king_queen_jack_nine_high.value).to be > ace_king_queen_jack_eight_high.value
      end
    end
  end
end