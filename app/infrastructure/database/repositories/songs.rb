# frozen_string_literal: true

module LyricLab
  module Repository
    # Repository for Project Entities
    class Songs
      def self.all
        Database::SongOrm.all.map { |db_song| rebuild_entity(db_song) }
      end

      def self.find_from_title_artist(title, artist_name_string)
        db_song = Database::SongOrm
          .where(title:, artist_name_string:)
          .first
        rebuild_entity(db_song)
      end

      def self.find(entity)
        find_origin_id(entity.origin_id)
      end

      def self.find_id(id)
        db_record = Database::SongOrm.first(id:)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::SongOrm.first(origin_id:)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        #raise 'Song already exists' if find(entity)
        return entity if find(entity)

        db_song = PersistSong.new(entity).call
        rebuild_entity(db_song)
      end

      def self.update(entity)
        # puts "Updating song #{entity.id}"
        db_song = Database::SongOrm.first(id: entity.id)
        # puts "DB SONG: #{db_song}"
        db_song.update(entity.to_attr_hash)
        # puts "updated DB SONG: #{db_song}"
        Vocabularies.update(entity.vocabulary)
        Lyrics.update(entity.lyrics)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        lyrics = Lyrics.rebuild_entity(db_record.lyrics)
        vocabulary = Vocabularies.rebuild_entity(db_record.vocabulary)
        Entity::Song.new(
          db_record.to_hash.merge(
            lyrics:,
            vocabulary:,
            is_instrumental: db_record.is_instrumental
          )
        )
      end

      # Helper class to persist song and its lyrics to database
      class PersistSong
        def initialize(entity)
          @entity = entity
        end

        def create_song
          Database::SongOrm.create(@entity.to_attr_hash)
        end

        def call
          lyrics = Lyrics.find_or_create(@entity.lyrics)
          vocabulary = Vocabularies.find_or_create(@entity.vocabulary)

          create_song.tap do |db_song|
            db_song.update(lyrics:)
            db_song.update(vocabulary:)
          end
        end
      end
    end
  end
end
