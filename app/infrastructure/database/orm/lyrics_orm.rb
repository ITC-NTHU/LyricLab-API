# frozen_string_literal: true

require 'sequel'

module LyricLab
  module Database
    # Object Relational Mapper for Lyrics Entities
    class LyricsOrm < Sequel::Model(:lyrics)
      one_to_many :song,
                  class: :'LyricLab::Database::SongOrm',
                  key: :lyrics_id

      plugin :timestamps, update_on_create: true
      plugin :whitelist_security

      set_allowed_columns :text, :is_mandarin, :is_instrumental, :is_explicit

      def self.find_or_create(lyrics_info)
        first(text: lyrics_info[:text]) || create(
          text: lyrics_info[:text],
          is_mandarin: lyrics_info[:is_mandarin],
          is_explicit: lyrics_info[:is_explicit]
        )
      end
    end
  end
end
