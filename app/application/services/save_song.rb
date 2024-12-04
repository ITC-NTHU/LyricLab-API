# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Transaction to store song from Spotify to database
    class SaveSong
      include Dry::Transaction

      step :save_song_to_database

      private

      def save_song_to_database(song)
        rebuilt = LyricLab::Repository::For.entity(song).create(song)
        Success(Response::ApiResult.new(status: :ok, message: rebuilt))
      rescue StandardError => e
        message = if e.message == 'Song already exists'
                    'song already exists in the db'
                  else
                    App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
                    'cannot persist the song to db'
                  end

        Failure(Response::ApiResult.new(status: :internal_error, message: message))
      end
    end
  end
end
