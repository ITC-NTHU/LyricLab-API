# LyricLab::Spotify::SongMapper
# .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
# .find_n(ARTIST_NAME, 6)

# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Load a song from the database
    class FindNRelevantSongs
      SPOTIFY_CLIENT_ID = LyricLab::App.config.SPOTIFY_CLIENT_ID
      SPOTIFY_CLIENT_SECRET = LyricLab::App.config.SPOTIFY_CLIENT_SECRET
      GOOGLE_CLIENT_KEY = LyricLab::App.config.GOOGLE_CLIENT_KEY
      include Dry::Transaction

      step :find_songs_on_apis
      step :filter_unrelevant_songs

      private

      def find_songs_on_apis(input)
        artist_name, number_of_songs = input
        songs = LyricLab::Spotify::SongMapper.new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
          .find_n(artist_name, number_of_songs)
        if songs.nil?
          return Failure(Response::ApiResult.new(status: :internal_error, message: 'cannot find song on spotify'))
        end

        Success(songs)
      rescue StandardError => e
        App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'cannot find the song'))
      end

      def filter_unrelevant_songs(input_songs)
        input_songs.filter!(&:relevant?)
        Success(Response::ApiResult.new(status: :ok, message: input_songs))
      rescue StandardError => e
        App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'cannot filter the songs for relavancy'))
      end
    end
  end
end
