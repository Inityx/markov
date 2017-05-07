# Modifiers for manipulating sentences
module Sentence
  SENTENCE_DELIMITERS = /\.|\?|!/
  SENTENCE_END = /#{SENTENCE_DELIMITERS}$/

  refine Enumerable do
    def moving_slice(n)
      Enumerator.new do |y|
        prev = take(n - 1)
        remain = drop(n - 1)
        return to_a if remain.empty?

        remain.each do |item|
          prev << item
          y << block_given? ? yield(*prev) : prev
          prev.shift
        end
      end
    end

    def by_sentence
      Enumerator.new do |y|
        buffer = ''

        each do |line|
          buffer << line
          chunks = buffer
            .split(SENTENCE_DELIMITERS)
            .map(&:chomp)
            .map(&:lstrip)

          while chunks.count > 1
            sentence = chunks.shift
            y << sentence unless sentence.empty?
          end

          remainder = chunks.first
          remainder << '.' if buffer =~ SENTENCE_END
          remainder << ' '

          buffer = remainder
        end

        y << (buffer.end_with?('.') ? buffer[0..-2] : buffer)
      end
    end
  end
end
