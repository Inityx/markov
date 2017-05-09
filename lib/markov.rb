require 'sentence'

# Markov chain generator
class Markov
  using Sentence

  WORD_DELIMITERS = / |"/

  # Word/count pair
  class Mapping
    attr_reader :word, :count

    def initialize(word)
      @word = word
      @count = 1
    end

    def increment
      @count += 1
    end

    def inspect
      "(#{word.inspect}: #{count})"
    end
  end

  def initialize(input = nil)
    @map = {}
    @starters = Array[]
    return unless input

    input = input.split("\n") if input.is_a? String
    train_text(input)
  end

  def train_text(text)
    text.by_sentence.each(&method(:train_sentence))
  end

  def train_sentence(sentence)
    words = sentence.downcase.split(WORD_DELIMITERS).reject(&:empty?)
    ([:start] + words + [:end])
      .moving_slice(3) { |key1, key2, value| add(key1, key2, value) }
      .count
  end

  def add(key1, key2, value)
    @starters << key2 if key1 == :start
    entries = @map[[key1, key2]] ||= Array[]

    if (existing = entries.select { |entry| entry.word == value }.first)
      existing.increment
      entries.sort_by!(&:count)
    else
      entries.unshift(Mapping.new(value))
    end
  end

  def best_next(k1, k2)
    entries = @map[[k1, k2]]
    seed = rand
    index = (
      (1 - (seed * seed * seed)) *
      (entries.count - 1)
    ).round

    entries[index].word
  end

  def random_sentence
    generator
      .take_while { |item| item != :end }
      .join(' ').capitalize.<<('.')
  end

  def generator
    Enumerator.new do |y|
      previous = :start
      current = @starters.sample
      loop do
        y << current
        previous, current = current, best_next(previous, current)
      end
    end
  end
end
