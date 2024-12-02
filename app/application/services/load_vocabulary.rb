# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Transaction to store project from Github API to database
    class LoadVocabulary
      include Dry::Transaction

      GPT_API_KEY = LyricLab::App.config.GPT_API_KEY

      step :find_song_db
      step :populate_vocabulary
      step :store_vocabulary

      private

      def find_song_db(input_id)
        song = Repository::For.klass(Entity::Song).find_spotify_id(input_id)
        Success(song)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: 'cannot access db'))
      end

      def populate_vocabulary(input_song)
        if input_song.vocabulary.unique_words.empty?
          input_song.vocabulary.gen_unique_words(input_song.lyrics.text, GPT_API_KEY)
        end
        Success(input_song)
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'cannot generate vocabulary'))
      end

      def store_vocabulary(input)
        if Repository::For.entity(input).find(input)
          Repository::For.entity(input).update(input)
        else
          Repository::For.entity(input).create(input)
        end
        Success(Response::ApiResult.new(status: :ok, message: input))
      rescue StandardError => e
        App.logger.error e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'having trouble writing into db'))
      end
    end
  end
end
