# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LyricLab
  # New types to define safe word attributes
  module Types
    include Dry.Types()
    LanguageLevel = Types::String.enum('beginner', 'novice1', 'novice2', 'level1', 'level2', 'level3', 'level4',
                                       'level5')
  end

  module Entity
    # Domain entity for lyrics
    class Word < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :characters, Strict::String
      attribute :translation, Strict::String
      attribute :pinyin, Strict::String
      attribute :language_level, Types::LanguageLevel.optional
      attribute :definition, Strict::String.optional
      attribute :word_type, Strict::String.optional
      attribute :example_sentence, Strict::String.optional

      def to_attr_hash
        to_hash.except(:id)
      end
    end
  end
end
