# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'

describe 'Tests lrclib API library' do
  before do
    VcrHelper.configure_vcr_for_lrclib
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Lyric information' do
    before do
      @api = LyricLab::Lrclib::LyricsMapper.new(GOOGLE_CLIENT_KEY)
    end

    it 'HAPPY: should provide correct lyric attributes' do
      lyrics, = @api.find(TRACK_NAME, ARTIST_NAME, false)
      _(lyrics.text).must_equal CORRECT_LYRICS.strip
      refute_nil lyrics.text
    end

    it 'SAD: should raise exception on incorrect song title' do
      # _(proc do
      #  @api.find('BAD_NAME', ARTIST_NAME)
      # end).must_raise LyricLab::Lrclib::Api::Response::NotFound
      result, = @api.find('BAD_NAME', ARTIST_NAME, false)
      assert_nil result.text, 'Expected text to be nil'
    end

    it 'SAD: should raise exception on incorrect artist' do
      result, = @api.find(TRACK_NAME, 'NO_ARTIST', false)
      assert_nil result.text, 'Expected text to be nil'
    end
  end
end
