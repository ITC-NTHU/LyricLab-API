# frozen_string_literal: true

require 'sequel'

module LyricLab
  module Database
    # Object Relational Mapper for Project Entities
    class VocabularyOrm < Sequel::Model(:vocabularies)
      many_to_many :unique_words,
                   class: :'LyricLab::Database::WordOrm',
                   join_table: :vocabularies_unique_words,
                   left_key: :vocabulary_id, right_key: :unique_word_id,
                   dependent: :destroy

      one_to_many :song,
                  class: :'LyricLab::Database::SongOrm',
                  key: :vocabulary_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(vocabulary_info)
        first(id: vocabulary_info[:id]) || create(vocabulary_info)
      end

      def self.find_or_create_song_id(song_id, vocabulary_info)
        song = SongOrm.first(id: song_id)
        song.vocabulary || create(vocabulary_info)
      end
    end
  end
end
