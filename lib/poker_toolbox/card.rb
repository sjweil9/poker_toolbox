# frozen_string_literal: true

module PokerToolbox
  class Card #:nodoc:
    attr_reader :suit

    def initialize(string)
      @rank, @suit = string.split('')
    end

    def value
      @value ||= calculate_value
    end

    def to_s
      "#{@rank}#{suit}"
    end

    private

    def calculate_value
      case @rank
      when 'A' then 14
      when 'K' then 13
      when 'Q' then 12
      when 'J' then 11
      when 'T' then 10
      else @rank.to_i
      end
    end
  end
end
