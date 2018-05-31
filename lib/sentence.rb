# frozen_string_literal: true

# Modifiers for manipulating sentences
module Sentence
  SENTENCE_DELIMITERS = /\.|\?|!/
  SENTENCE_END = /#{SENTENCE_DELIMITERS}$/

  refine Enumerable do
    def moving_slice(count)
      # TODO: move to Array and use slicing
      Enumerator.new do |yielder|
        prev = take(count - 1)
        remain = drop(count - 1)

        if remain.any?
          remain.each do |item|
            prev << item
            yielder << (block_given? ? yield(prev) : prev.clone)
            prev.shift
          end
        else
          yielder << (block_given? ? yield(prev) : prev.clone)
        end
      end
    end

    def by_sentence
      Enumerator.new do |yielder|
        buffer = +''

        each do |line|
          buffer << line
          chunks = buffer
            .split(SENTENCE_DELIMITERS)
            .map(&:chomp)
            .map(&:lstrip)

          while chunks.count > 1
            sentence = chunks.shift
            yielder << sentence unless sentence.empty?
          end
          remainder = chunks.first
          remainder << '.' if buffer =~ SENTENCE_END
          remainder << ' '

          buffer = remainder
        end

        unless buffer == '. '
          yielder << (buffer.end_with?('.') ? buffer[0..-2] : buffer)
        end
      end
    end
  end
end
