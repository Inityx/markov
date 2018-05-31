# frozen_string_literal: true

require 'sentence'

# Markov chain generator
class Markov
  using Sentence

  WORD_DELIMITERS = / |"/

  # Word/count pair
  class Mapping
    attr_reader :word
    attr_accessor :count

    def initialize(word)
      @word = word
      @count = 1
    end

    def inspect
      "(#{word.inspect}: #{count})"
    end
  end

  def initialize(input = nil)
    @map = Hash[]
    @starters = Array[]
    return unless input

    input = input.split("\n") if input.is_a? String
    train_text(input)
  end

  def train_text(text)
    text.by_sentence.each(&method(:train_sentence))
  end

  def train_sentence(sentence)
    words = sentence
      .downcase
      .split(WORD_DELIMITERS)
      .reject(&:empty?)

    return if words.empty?

    words = [:start] + words + [:end]

    words
      .moving_slice(3)
      .each { |slice| add(*slice) }
  end

  def add(key1, key2, value)
    mappings = (@map[[key1, key2]] ||= Array[])
    @starters << key2 if key1 == :start

    existing = mappings.find { |mapping| mapping.word == value }

    if existing
      existing.count += 1
      mappings.sort_by!(&:count)
    else
      mappings.unshift(Mapping.new(value))
    end
  end

  def next_word(key1, key2, prob_bias)
    mappings = @map[[key1, key2]]
    seed = rand

    # weighted probabilistic selection favoring later elements
    index = (
      (1 - seed**prob_bias) *
      (mappings.count - 1)
    ).round

    mappings[index].word
  end

  def random_sentence
    generator
      .take_while { |item| item != :end }
      .join(' ')
      .capitalize
      .<<('.')
  end

  def generator(prob_bias = 3)
    Enumerator.new do |yielder|
      prev, curr = :start, @starters.sample
      loop do
        yielder << curr
        prev, curr = curr, next_word(prev, curr, prob_bias)
      end
    end
  end
end
