require "json"

module PokerToolbox
  class Hand
    def self.from_json(json)
      cards = JSON.parse(json).map do |string|
        Card.new(string)
      end

      new(cards)
    end

    attr_reader :cards

    def initialize(cards)
      @cards = cards.sort_by { |card| -card.value }
    end

    def value
      @value ||= calculate_value
    end

    private unless $TESTING

    attr_reader :top_pair_card, :second_pair_card

    def calculate_value
      case hand_rank
      when :straight_flush
        8_000_000 + highest_straight_card
      when :four_of_a_kind
        7_000_000 + (top_pair_card * 15) + second_pair_card
      when :full_house
        6_000_000 + (top_pair_card * 15) + second_pair_card
      when :flush
        5_000_000 + cards.first.value
      when :straight
        4_000_000 + highest_straight_card
      when :three_of_a_kind
        3_000_000 + value_map[1].map.with_index { |v, i| v * 10 ** (2 - i) }.reduce(0, :+)
      when :two_pair
        2_000_000 + (top_pair_card * 1500) + (second_pair_card * 15) + value_map[1].first
      when :pair
        1_000_000 + (top_pair_card * 10000) + value_map[1].map.with_index { |v, i| v * 10 ** (2 - i) }.reduce(0, :+)
      when :high_card
        cards.map.with_index { |c, i| c.value * 10 ** (4 - i) }.reduce(0, :+)
      end
    end

    def hand_rank
      if straight?
        flush? ? :straight_flush : :straight
      else
        if flush?
          # not possible to have a better hand if flush and not straight-flush (four of a kind/full house are impossible)
          :flush
        else
          if (@top_pair_card = value_map[4].first)
            @second_pair_card = value_map[1].first
            :four_of_a_kind
          elsif (@top_pair_card = value_map[3].first) && (@second_pair_card = value_map[2].first)
            :full_house
          elsif (@top_pair_card = value_map[3].first)
            :three_of_a_kind
          elsif value_map[2].size == 2
            @top_pair_card = value_map[2].max
            @second_pair_card = value_map[2].min
            :two_pair
          elsif (@top_pair_card = value_map[2].first)
            :pair
          else
            :high_card
          end
        end
      end
    end

    def flush?
      return @flush unless @flush.nil?

      @flush = cards.map(&:suit).uniq.size == 1
    end

    def straight?
      return @straight unless @straight.nil?

      values = cards.map(&:value)
      # handle only valid straight where ace is low
      return @straight = true if values.first == 14 && values.last(4) == [5, 4, 3, 2]

      # otherwise check all cards are in descending order by 1
      @straight = check_for_straight(values)
    end

    def check_for_straight(values)
      is_straight = values.reduce(nil) do |current_val, next_val|
        break false unless current_val.nil? || next_val == current_val - 1

        next_val
      end

      # if it finished with an integer, it never broke false, so it must be a straight
      is_straight.is_a?(Numeric)
    end

    def value_map
      # build a map of count => card
      hash_with_default = Hash.new { |hash, key| hash[key] = [] }
      cards.map(&:value).tally.reduce(hash_with_default) do |hash, (card, count)|
        hash[count] << card
        hash
      end
    end

    def highest_straight_card
      # check for wheel, make sure high card is only 5 in that case
      return 5 if cards.first.value == 14 && cards[1].value == 5

      cards.first.value
    end
  end
end