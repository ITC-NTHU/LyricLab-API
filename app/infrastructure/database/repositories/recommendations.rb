# frozen_string_literal: true

module LyricLab
  module Repository
    # Repository for Recommendations
    class Recommendations
      def self.all
        Database::RecommendationOrm.all.map { |db_recommendation| rebuild_entity(db_recommendation) }
      end

      def self.find_id(id)
        rebuild_entity Database::RecommendationOrm.first(id:)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        record = {
          title: db_record.title, artist_name_string: db_record.artist_name_string,
          search_cnt: db_record.search_cnt, origin_id: db_record.origin_id,
          language_difficulty: db_record.language_difficulty
        }

        Entity::Recommendation.new(record)
      end

      def self.top_searched_songs
        db_recommendations = Database::RecommendationOrm.order(Sequel.desc(:search_cnt)).limit(5)
        db_recommendations.map { |db_recommendation| rebuild_entity(db_recommendation) }
      end

      def self.find_origin_id(origin_id)
        db_record = Database::RecommendationOrm.first(origin_id:)
        rebuild_entity(db_record)
      end

      def self.increment_cnt(origin_id)
        Database::RecommendationOrm.where(origin_id:).update(search_cnt: Sequel[:search_cnt] + 1)
        db_record = Database::RecommendationOrm.where(origin_id:).first
        rebuild_entity(db_record)
      end

      def self.create(entity)
        if find_origin_id(entity.origin_id)
          increment_cnt(entity.origin_id)
        else
          db_recommendation = PersistRecommendation.new(entity).create_recommendation
          rebuild_entity(db_recommendation)
        end
      end

      # Persist a recommendation to the database
      class PersistRecommendation
        def initialize(entity)
          @entity = entity
        end

        def create_recommendation
          Database::RecommendationOrm.create(@entity.to_attr_hash)
        end
      end
    end
  end
end
