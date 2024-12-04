# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Load a song from the database
    class LoadSongs
      include Dry::Transaction

      step :load_songs_from_database

      private

      def load_songs_from_database(input)
        songs = input.map { |i| Repository::For.klass(Entity::Song).find_origin_id(i) }
        list = Response::SongsList.new(songs) 
        Success(Response::ApiResult.new(status: :ok, message: list))
      rescue StandardError => e
        App.logger.error e
        App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'cannot load songs'))
      end
    end
  end
end
