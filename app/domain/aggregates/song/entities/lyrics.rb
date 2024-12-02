# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module LyricLab
  module Entity
    # Domain entity for lyrics
    class Lyrics < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :text, Strict::String.optional
      attribute :is_mandarin, Strict::Bool.optional
      # attribute :instrumental?, Strict::Bool.optional
      attribute :is_explicit, Strict::Bool.optional

      def to_attr_hash
        to_hash.except(:id)
      end

      def mandarin?
        is_mandarin
      end

      def explicit?
        is_explicit
      end
    end
  end
end
