# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Load search results from Spotify API
    class LoadSearchResults
      include Dry::Transaction

      step :validate_search_query
      step :create_entity
      step :check_relevancy
      step :store_song

      SPOTIFY_CLIENT_ID = LyricLab::App.config.SPOTIFY_CLIENT_ID
      SPOTIFY_CLIENT_SECRET = LyricLab::App.config.SPOTIFY_CLIENT_SECRET
      GOOGLE_CLIENT_KEY = LyricLab::App.config.GOOGLE_CLIENT_KEY

      private

      def validate_search_query(input)
        query = input.call
        if query.success?
          Success(query.value!)
        else
          Failure(query.failure)
        end
      rescue StandardError => e
        App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'Validating search query went wrong'))
      end

      def create_entity(input) # rubocop:disable Metrics/MethodLength
        search_results = Spotify::SongMapper
          .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
          .find_n(input, 5)
        songs_with_lyrics = search_results.reject { |song| song.lyrics.nil? }
        if songs_with_lyrics.empty?
          Failure(Response::ApiResult.new(status: :not_found, message: 'no lyrics found'))
        else
          Success(songs_with_lyrics:)
        end
      rescue StandardError
        # App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'Oops something went wrong'))
      end

      def check_relevancy(input)
        relevant_songs = input[:songs_with_lyrics].select(&:relevant?)
        if relevant_songs.empty?
          Failure(Response::ApiResult.new(status: :not_found, message: 'songs are not mandarin or have no lyrics'))
        else
          Success(relevant_songs:)
        end
      rescue StandardError
        # App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'Check relevancy went wrong'))
      end

      def store_song(input)
        input[:relevant_songs].each { |song| Repository::For.entity(song).create(song) }
          .then { |songs| Response::SongsList.new(songs) }
          .then { |list| Response::ApiResult.new(status: :created, message: list) }
          .then { |result| Success(result) }
      rescue StandardError
        # App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'having trouble accessing the database'))
      end
    end
  end
end
