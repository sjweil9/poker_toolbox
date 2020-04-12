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

    def calculate_value
      case hank_rank
      when :straight_flush then 8000 + cards.first.value
      when :four_of_a_kind then 7000 + (top_pair_card.value * 15) + high_card.value
      end
    end

    def top_pair_card
      @top_pair_card
    end

    def hand_rank

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
  end
end