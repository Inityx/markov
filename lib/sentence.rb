# Modifiers for manipulating sentences
module Sentence
  SENTENCE_DELIMITERS = /\.|\?|!/
  SENTENCE_END = /#{SENTENCE_DELIMITERS}$/

  refine Enumerable do
    def moving_slice(n)
      Enumerator.new do |yielder|
        prev = take(n - 1)
        remain = drop(n - 1)
        return to_a if remain.empty?

        remain.each do |item|
          prev << item
          yielder << block_given? ? yield(*prev) : prev
          prev.shift
        end
      end
    end

    def by_sentence
      Enumerator.new do |yielder|
        buffer = ''

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

        yielder << (buffer.end_with?('.') ? buffer[0..-2] : buffer)
      end
    end
  end
end
