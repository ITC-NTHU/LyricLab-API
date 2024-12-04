# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'lyrics'
require_relative 'vocabulary'

module LyricLab
  module Entity
    # Domain Entity for Songs
    class Song < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :title, Strict::String
      attribute :origin_id, Strict::String
      attribute :popularity, Strict::Integer
      attribute :preview_url, Strict::String.optional
      attribute :album_name, Strict::String
      attribute :artist_name_string, Strict::String
      attribute :cover_image_url_big, Strict::String.optional
      attribute :cover_image_url_medium, Strict::String.optional
      attribute :cover_image_url_small, Strict::String.optional
      attribute :is_instrumental, Strict::Bool.optional
      attribute :vocabulary, Instance(Vocabulary)
      attribute :lyrics, Lyrics

      # def initialize(title, artist_name_string, lyrics, is_instrumental)
      #   @title = title
      #   @artist_name_string = artist_name_string
      #   @lyrics = lyrics
      #   @is_instrumental = is_instrumental
      # end

      def to_attr_hash
        to_hash.except(:id, :lyrics, :vocabulary)
      end

      def instrumental?
        is_instrumental
      end

      def relevant?
        !instrumental? && lyrics.mandarin?
      end
    end
  end
end
