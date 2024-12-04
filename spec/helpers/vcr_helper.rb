# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
module VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  LRCLIB_CASSETTE = 'lrclib_api'
  SPOTIFY_CASSETTE = 'spotify_api'
  GPT_CASSETTE = 'gpt_api'
  SERVICES_CASSETTE = 'services'
  SERVICES_CASSETTE_2 = 'services2'
  API_CASSETTE = 'api'

  def self.setup_vcr
    VCR.configure do |config|
      config.cassette_library_dir = CASSETTES_FOLDER
      config.hook_into :webmock
    end
  end

  def self.configure
    VCR.configure do |config|
      config.cassette_library_dir = CASSETTES_FOLDER
      config.hook_into :webmock

      config.before_record do |i|
        i.response.headers.delete('Set-Cookie')
        i.request.headers.delete('Authorization')

        u = URI.parse(i.request.uri)
        i.request.uri.sub!(%r{://.*#{Regexp.escape(u.host)}}, "://#{u.host}")

        i.ignore! if i.request.uri.include?('https://translate.googleapis.com/language/translate/v2/detect')
      end

      config.filter_sensitive_data('<REDACTED>') { SPOTIFY_CLIENT_ID }
      config.filter_sensitive_data('<REDACTED>') { CGI.escape(SPOTIFY_CLIENT_ID) }
      config.filter_sensitive_data('<REDACTED>') { SPOTIFY_CLIENT_SECRET }
      config.filter_sensitive_data('<REDACTED>') { CGI.escape(SPOTIFY_CLIENT_SECRET) }
      config.filter_sensitive_data('<REDACTED>') { GOOGLE_CLIENT_KEY }
      config.filter_sensitive_data('<REDACTED>') { CGI.escape(GOOGLE_CLIENT_KEY) }

      config.filter_sensitive_data('<REDACTED>') do |interaction|
        token_match = /"access_token":"(.*?)"/.match(interaction.response.body)
        token_match[1] if token_match
      end
    end
  end

  def self.configure_vcr_for_gpt
    configure

    VCR.insert_cassette(
      GPT_CASSETTE,
      record: :new_episodes,
      match_requests_on: %i[uri]
    )
  end

  def self.configure_vcr_for_services_record(recording: :new_episodes)
    configure

    VCR.insert_cassette(
      SERVICES_CASSETTE,
      record: recording,
      match_requests_on: %i[method body]
    )
  end

  def self.configure_vcr_for_api(recording: :new_episodes)
    configure

    VCR.insert_cassette(
      API_CASSETTE,
      record: recording,
      match_requests_on: %i[uri method body]
    )
  end

  def self.configure_vcr_for_spotify(recording: :new_episodes)
    configure

    VCR.insert_cassette(
      SPOTIFY_CASSETTE,
      record: recording,
      match_requests_on: %i[method body]
    )
  end

  def self.configure_vcr_for_lrclib(recording: :new_episodes) # rubocop:disable Metrics/MethodLength
    VCR.configure do |config|
      config.cassette_library_dir = CASSETTES_FOLDER
      config.hook_into :webmock

      config.filter_sensitive_data('<REDACTED>') { GOOGLE_CLIENT_KEY }
      config.filter_sensitive_data('<REDACTED>') { CGI.escape(GOOGLE_CLIENT_KEY) }
    end
    VCR.insert_cassette(
      LRCLIB_CASSETTE,
      record: recording,
      match_requests_on: %i[method uri headers]
    )
  end

  # For Gpt
  def self.configure_vcr_for_openai # rubocop:disable Metrics/MethodLength
    VCR.configure do |config|
      config.filter_sensitive_data('<GPT_API_KEY>') { ENV['GPT_API_KEY'] || OPENAI_API_KEY }
      config.filter_sensitive_data('<AUTHORIZATION>') do |interaction|
        auth_header = interaction.request.headers['Authorization']&.first
        auth_header if auth_header
      end
    end

    VCR.insert_cassette(
      GPT_CASSETTE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
