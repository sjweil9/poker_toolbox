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

    private

    def calculate_value
      case hank_rank
      when :straight_flush then 8000 + cards.first.value
      when :four_of_a_kind then 7000 + (top_pair_card.value * 15) + high_card.value
      end
    end

    def straight_flush

    end

    def top_pair_card
      @top_pair_card
    end

    def hand_rank

    end

    def flush?
      cards.map(&:suit).uniq.size == 1
    end
  end
end