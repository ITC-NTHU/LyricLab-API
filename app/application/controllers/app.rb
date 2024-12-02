# frozen_string_literal: true

require 'rack' # for Rack::MethodOverride
require 'roda'

module LyricLab
  # Web App
  class App < Roda
    # plugin :sessions, secret: config.SESSION_SECRET
    plugin :halt
    plugin :caching

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "LyricLab API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message:)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do # rubocop:disable Metrics/BlockLength
        routing.on 'recommendations' do
          # return recommendations as array of objects
          # GET /api/v1/recommendations
          routing.get do
            result = Service::ListRecommendations.new.call

            if result.failure?
              failed = Representer::HttpResponse.new(result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end
            # puts("Recommendations: #{result.value!.message}")
            http_response = Representer::HttpResponse.new(result.value!)
            response.status = http_response.http_status_code
            Representer::RecommendationsList.new(result.value!.message).to_json
          end
        end

        routing.on 'search_results' do

          routing.on String do |ids|
            routing.get do
              ids = ids.split('-')
              result = Service::LoadSongs.new.call(ids)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::SearchResults.new(
                result.value!.message
              ).to_json
            end
          end

          routing.is do
            # return search results in form of song objects
            # GET /api/v1/search_results?search_query={search_query}
            routing.get do
              search_query = Request::EncodedSearchQuery.new(routing.params)
              result = Service::LoadSearchResults.new.call(search_query)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::SearchResults.new(
                result.value!.message
              ).to_json
            end
          end
        end

        routing.on 'songs' do
          routing.on String do |origin_id|
            # record recommendation update
            # POST /api/v1/songs/{origin_id}
            routing.post do
              result = Service::RecordRecommendation.new.call(origin_id)
              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Recommendation.new(result.value!.message).to_json
            end

            # return metadata for single song object
            # GET /api/v1/songs/{origin_id}
            routing.get do
              result = Service::LoadSong.new.call(origin_id)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::Song.new(
                result.value!.message
              ).to_json
            end
          end
        end

        routing.on 'vocabularies' do
          routing.on String do |origin_id|
            # return vocabularies
            # GET /api/v1/vocabularies/{origin_id}
            routing.get do
              result = Service::LoadVocabulary.new.call(origin_id)
              # puts "Result: #{result.inspect}"
              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::Song.new(
                result.value!.message
              ).to_json
            end
          end
        end
      end
    end
  end
end
