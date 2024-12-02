# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LyricLab
  module Entity
    # Domain Entity for Recommendations
    class Recommendation < Dry::Struct
      include Dry.Types

      attribute :title, Strict::String
      attribute :artist_name_string, Strict::String
      attribute :search_cnt, Strict::Integer
      attribute :origin_id, Strict::String
      attribute :language_difficulty, Nominal::Decimal

      def to_attr_hash
        to_hash
      end
    end
  end
end
