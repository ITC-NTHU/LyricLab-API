# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
require 'rack/test'

def app
  LyricLab::App
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_api
    DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Root route' do
    it 'should successfully return root information' do
      get '/'
      _(last_response.status).must_equal 200

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'ok'
      _(body['message']).must_include 'api/v1'
    end
  end

  describe 'Get song metadata' do
    it 'should successfully return song metadata' do
      song = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find("#{ARTIST_NAME} #{TRACK_NAME}")

      LyricLab::Service::SaveSong.new.call(song)

      get "/api/v1/songs/#{song.origin_id}"

      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body

      _(result['artist_name_string']).must_equal song.artist_name_string
      _(result['title']).must_equal song.title
      _(result['origin_id']).must_equal song.origin_id
    end
  end

  describe 'Search route' do
    it 'should be able to search based on search query' do
      encoded_query = LyricLab::Request::EncodedSearchQuery.to_encoded(ARTIST_NAME)

      get "/api/v1/search_results?search_query=#{encoded_query}"

      _(last_response.status).must_equal 201

      songs = JSON.parse(last_response.body)
      song = songs['songs'].first
      _(song['artist_name_string']).must_equal ARTIST_NAME
    end

    it 'should report error for invalid search query' do
      encoded_query = LyricLab::Request::EncodedSearchQuery.to_encoded('valentin strykalo')

      get "/api/v1/search_results?search_query=#{encoded_query}"

      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['message']).must_include 'not'
    end

    it 'should report error for empty search query' do
      encoded_query = LyricLab::Request::EncodedSearchQuery.to_encoded('')
      get "/api/v1/search_results?search_query=#{encoded_query}"

      _(last_response.status).must_equal 422
      _(JSON.parse(last_response.body)['message']).must_include 'Empty'
    end
  end

  describe 'Get targeted recommendations route' do
    before do
      search_strings = ['No Party for Cao Dong']
      # , 'Wo bu shi', 'ni hao', 'anquan', 'bangzhu wo']
      search_strings.each do |search_string|
        search_query = LyricLab::Request::EncodedSearchQuery.to_request(search_string)
        LyricLab::Service::LoadSearchResults.new.call(search_query)
        searched_origin_ids = LyricLab::Database::SongOrm.all.map(&:origin_id)
        searched_origin_ids.each do |origin_id|
          get "/api/v1/vocabularies/#{origin_id}"
          post "/api/v1/songs/#{origin_id}"
        end
      end
    end
    it 'should successfully return a recommendations list targeted for a language_difficulty' do
      language_difficulties = %w[1 2 3 4 5 6 7]

      recommendations_list = []

      language_difficulties.each do |language_difficulty|
        get "/api/v1/recommendations/targeted/?language_difficulty=#{language_difficulty}"

        _(last_response.status).must_equal 200
        # TODO: check if the correct songs have been returned
        recommendations_list << JSON.parse(last_response.body)['recommendations']
      end
    end
  end

  describe 'Get recommendations route' do
    it 'should successfully return recommendations list' do
      search_query = LyricLab::Request::EncodedSearchQuery.to_request('No Party For Cao Dong 山海')
      LyricLab::Service::LoadSearchResults.new.call(search_query)
      searched_origin_ids = LyricLab::Database::SongOrm.all.map(&:origin_id)
      searched_origin_ids.each do |origin_id|
        get "/api/v1/vocabularies/#{origin_id}"
        post "/api/v1/songs/#{origin_id}"
      end

      get '/api/v1/recommendations'

      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      songs = response['recommendations']
      _(songs.count != 0).must_equal true

      song = songs.first
      _(song['title']).must_include '山海'
    end
  end

  describe 'Get song with vocabulary route' do
    it 'should successfully return song with vocabulary' do
      song = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find("#{ARTIST_NAME} #{TRACK_NAME}")

      LyricLab::Service::SaveSong.new.call(song)

      get "/api/v1/vocabularies/#{song.origin_id}"
      get "/api/v1/vocabularies/#{song.origin_id}"

      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body

      _(result['vocabulary']['unique_words'].empty?).must_equal false
      _(result['artist_name_string']).must_equal song.artist_name_string
      _(result['title']).must_equal song.title
      _(result['origin_id']).must_equal song.origin_id

      LyricLab::Representer::Song.new(
        LyricLab::Representer::OpenStructWithLinks.new
      ).from_json last_response.body
      # _(link.links['get_vocabulary'].href).must_include 'http' TODO: @Irina
    end
  end
end
