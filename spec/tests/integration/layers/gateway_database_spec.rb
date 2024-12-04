# frozen_string_literal: false

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'Integration Tests of Spotify API and Database' do
  VcrHelper.setup_vcr
  before do
    VcrHelper.configure_vcr_for_spotify
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store song data' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to save song data from Spotify to database' do
      song = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
        .find(CORRECT_SONG['title'])

      rebuilt = LyricLab::Repository::For.entity(song).create(song)

      _(rebuilt.title).must_equal(song.title)
      _(rebuilt.origin_id).must_equal(song.origin_id)
      _(rebuilt.popularity).must_equal(song.popularity)
      _(rebuilt.preview_url).must_equal(song.preview_url)
      _(rebuilt.album_name).must_equal(song.album_name)
      _(rebuilt.artist_name_string).must_equal(song.artist_name_string)
      _(rebuilt.cover_image_url_big).must_equal(song.cover_image_url_big)
      _(rebuilt.cover_image_url_medium).must_equal(song.cover_image_url_medium)
      _(rebuilt.cover_image_url_small).must_equal(song.cover_image_url_small)
      _(rebuilt.lyrics.is_explicit).must_equal(song.lyrics.is_explicit)
      _(rebuilt.lyrics.is_mandarin).must_equal(song.lyrics.is_mandarin)
      _(rebuilt.lyrics.text).must_equal(song.lyrics.text)
      _(rebuilt.is_instrumental).must_equal(song.is_instrumental)
    end
  end
end
