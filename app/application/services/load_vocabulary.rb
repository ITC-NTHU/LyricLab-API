# frozen_string_literal: true

require 'dry/transaction'

module LyricLab
  module Service
    # Load vocabulary from db or ChatGPT API
    class LoadVocabulary
      include Dry::Transaction

      step :find_song_db
      step :populate_vocabulary
      step :store_vocabulary

      private

      def find_song_db(input_id)
        song = Repository::For.klass(Entity::Song).find_origin_id(input_id)
        Success(song)
      rescue StandardError => e
        App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'cannot access db'))
      end

      def populate_vocabulary(input_song)
        input_song.vocabulary.generate_content if input_song.vocabulary.unique_words.empty?
        Success(input_song)
      rescue StandardError => e
        App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'cannot generate vocabulary'))
      end

      def store_vocabulary(input_song)
        if Repository::For.entity(input_song).find(input_song)
          Repository::For.entity(input_song).update(input_song)
        else
          Repository::For.entity(input_song).create(input_song)
        end
        Success(Response::ApiResult.new(status: :ok, message: input_song))
      rescue StandardError => e
        App.logger.error("#{e.message}\n#{e.backtrace&.join("\n")}")
        Failure(Response::ApiResult.new(status: :internal_error, message: 'having trouble writing into db'))
      end
    end
  end
end
