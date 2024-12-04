# frozen_string_literal: true

require 'base64'
require 'dry/monads'
require 'json'

module LyricLab
  module Request
    # Search query list request parser
    class EncodedSearchQuery
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
      end

      # Use in API to parse incoming search query request
      def call # rubocop:disable Metrics/MethodLength
        if JSON.parse(decode(@params['search_query'])).empty?
          Failure(Response::ApiResult.new(status: :cannot_process, message: 'Empty search query'))
        else
          Success(JSON.parse(decode(@params['search_query'])))
        end
      rescue StandardError
        Failure(
          Response::ApiResult.new(
            status: :bad_request,
            message: 'Search query not found'
          )
        )
      end

      # Decode params
      def decode(param)
        Base64.urlsafe_decode64(param)
      end

      # Client App will encode params to send as a string
      # - Use this method to create encoded params for testing
      def self.to_encoded(search_query)
        Base64.urlsafe_encode64(search_query.to_json)
      end

      # Use in tests to create a SearchQuery object from a search_query
      def self.to_request(search_query)
        EncodedSearchQuery.new('search_query' => to_encoded(search_query))
      end
    end
  end
end
