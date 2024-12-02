# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'

describe 'Test Spotify API library' do
  before do
    VcrHelper.configure_vcr_for_spotify
  end

  after do
    VcrHelper.eject_vcr
  end
  describe 'Song information' do
    before do
      @api = LyricLab::Spotify::SongMapper
        .new(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, GOOGLE_CLIENT_KEY)
    end

    it 'HAPPY: should provide correct song attributes' do
      song = @api.find(CORRECT_SONG['title'])
      _(song.title).must_equal CORRECT_SONG['title']
      _(song.artist_name_string).must_equal CORRECT_SONG['artist_name_string']
      _(song.popularity).must_equal CORRECT_SONG['popularity']
      # _(song.preview_url).must_equal CORRECT_SONG['preview_url'] this url is dynamic
      _(song.album_name).must_equal CORRECT_SONG['album_name']
      _(song.cover_image_url_big).must_equal CORRECT_SONG['cover_image_url_big']
      _(song.cover_image_url_medium).must_equal CORRECT_SONG['cover_image_url_medium']
      _(song.cover_image_url_small).must_equal CORRECT_SONG['cover_image_url_small']
      _(song.lyrics.is_explicit).must_equal CORRECT_SONG['is_explicit']
      _(song.lyrics.is_mandarin).must_equal CORRECT_SONG['is_mandarin']
      _(song.is_instrumental).must_equal CORRECT_SONG['is_instrumental']
      _(song.origin_id).must_equal CORRECT_SONG['origin_id']
    end

    # it 'HAPPY: should provide 2 search result songs' do
    #  songs = @api.find_n(CORRECT_SONG['artist_name_string'], 2)
    #  _(songs.length).must_equal 2
    # end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        LyricLab::Spotify::SongMapper
          .new(SPOTIFY_CLIENT_ID, 'BAD_CLIENT_SECRET_ID', GOOGLE_CLIENT_KEY)
          .find(CORRECT_SONG['title'])
      end).must_raise LyricLab::Spotify::Api::Response::BadRequest
    end
  end
end
