# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require 'dry-initializer'

require_relative '../values/word'

module LyricLab
  module Entity
    # Domain entity for vocabulary
    class Vocabulary
      extend Dry::Initializer

      LANGUAGE_LEVELS = %i[beginner novice1 novice2 level1 level2 level3 level4 level5].freeze

      option :id, proc(&:to_i), optional: true
      option :unique_words, default: proc { [] }
      option :sep_text, default: proc { '' }
      option :raw_text, default: proc { '' }
      option :vocabulary_factory, default: proc {}
      option :language_difficulty, proc(&:to_f), optional: true
      # language_difficulty 0: beginner -> 7: level5

      def to_attr_hash
        {
          sep_text:, raw_text:, language_difficulty:
        }
      end

      def calculate_language_difficulty_from_words
        # puts("unique_words: #{@unique_words.inspect}")
        raise 'Vocabulary not populated' if @unique_words.empty?

        # puts "unique words language levels: #{@unique_words.map { |word| word.language_level.strip.to_sym }}"
        diff_sum = @unique_words.map { |word| LANGUAGE_LEVELS.index(word.language_level.strip.to_sym) }.sum
        # puts "diff_sum: #{diff_sum}, length: #{@unique_words.length}"
        # puts("diff_sum: #{diff_sum}, length: #{@unique_words.length}")
        @language_difficulty = diff_sum.to_f / @unique_words.length
        # puts "language_difficulty: #{@language_difficulty}"
      end

      def generate_content
        # puts 'Generating vocabulary content'
        raise 'Vocabulary already populated' if !@unique_words.empty? && sep_text
        raise 'No text to generate vocabulary' if @raw_text.nil?
        raise 'No vocabulary factory' if @vocabulary_factory.nil?

        unique_word_strings = separate_words(@raw_text)
        # puts "@raw_text: #{!@raw_text.empty?}"
        # puts "unique_word_strings: #{unique_word_strings}"
        database_word_objects, api_words = @vocabulary_factory.separate_existing_and_new_words(unique_word_strings)
        # puts "database_word_objects: #{database_word_objects.first.inspect}"
        # puts "api_words: #{api_words.first.inspect}"
        api_word_data = @vocabulary_factory.generate_words_metadata(api_words)
        # puts "api_word_data: #{api_word_data.first.inspect}"
        api_word_data.each do |word_data|
          word_data[:language_level] = word_data[:language_level].gsub(/[^a-z0-9]/, '')
        end
        api_word_objects = @vocabulary_factory.build_words_from_hash(api_word_data)
        @unique_words = database_word_objects.concat(api_word_objects)
        # puts "unique_words: #{@unique_words.first.inspect}"

        calculate_language_difficulty_from_words unless @unique_words.empty?
      end

      def separate_words(raw_text)
        text = vocabulary_factory.convert_to_traditional(raw_text)
        @sep_text = vocabulary_factory.extract_separated_text(text)
        @sep_text.split.map(&:strip).reject(&:empty?).uniq
      end
    end
  end
end
