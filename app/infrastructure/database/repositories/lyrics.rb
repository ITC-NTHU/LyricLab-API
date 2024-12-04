# frozen_string_literal: true

module LyricLab
  module Repository
    # Repository for Lyrics
    class Lyrics
      def self.find_id(id)
        rebuild_entity Database::LyricsOrm.first(id:)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Lyrics.new(
          id: db_record.id,
          text: db_record.text,
          is_mandarin: db_record.is_mandarin,
          is_explicit: db_record.is_explicit
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_lyrics|
          Lyrics.rebuild_entity(db_lyrics)
        end
      end

      def self.find_or_create(entity)
        Database::LyricsOrm.find_or_create(entity.to_attr_hash)
      end

      def self.update(entity)
        # puts "UPDATE LYRICS: #{entity}"
        db_lyrics = Database::LyricsOrm.first(id: entity.id)
        db_lyrics.update(entity.to_attr_hash)
      end

      def self.find_song_id(song_id)
        Database::SongOrm.first(id: song_id).lyrics
      end
    end
  end
end
