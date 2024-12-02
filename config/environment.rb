# frozen_string_literal: true

require 'roda'
require 'yaml'
require 'figaro'
require 'sequel'
require 'rack/session'
require 'logger'
require 'rack/cache'
require 'redis-rack-cache'
module LyricLab
  # Environment specific configuration
  class App < Roda
    plugin :environments

    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment:,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    def self.config = Figaro.env

    configure :development, :production do
      plugin :common_logger, $stderr
    end

    # Setup Cacheing mechanism
    configure :development do
      use Rack::Cache,
          verbose: true,
          metastore: 'file:_cache/rack/meta',
          entitystore: 'file:_cache/rack/body'
    end

    configure :production do
      use Rack::Cache,
          verbose: true,
          metastore: "#{config.REDISCLOUD_URL}/0/metastore",
          entitystore: "#{config.REDISCLOUD_URL}/0/entitystore"
    end

    # Automated HTTP stubbing for testing only
    configure :app_test do
      require_relative '../spec/helpers/vcr_helper'
      VcrHelper.setup_vcr
      VcrHelper.configure_vcr_for_github(recording: :none)
    end

    use Rack::Session::Cookie, secret: config.SESSION_SECRET

    configure :development, :test do
      require 'pry'; # for breakpoints
      ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
    end

    # Database Setup (ensure DATABASE_URL is already set on production)
    @db = Sequel.connect(ENV.fetch('DATABASE_URL'))
    def self.db = @db # rubocop:disable Style/TrivialAccessors

    # Logger Setup
    @logger = Logger.new($stderr)
    class << self
      attr_reader :logger
    end

    # Word List Setup (load into memory)
    # word_list[[characters, pinyin, word_type], ...]
    @word_list = YAML.load_file('files/mandarin_word_list.yml')
    @merged_word_list = @word_list.values.flatten(1)

    # [beginner, novice1, novice2, level1, level2, level3, level4, level5]
    @list_indexes = [0]
    current_index = 0

    @word_list.each_value do |list|
      current_index += list.size
      @list_indexes << current_index
    end

    @merged_word_list = @merged_word_list.map! { |word| word[0] }
    class << self
      attr_reader :merged_word_list
    end
    def self.list_indexes = @list_indexes # rubocop:disable Style/TrivialAccessors
    def self.word_list = @word_list # rubocop:disable Style/TrivialAccessors
  end
end
