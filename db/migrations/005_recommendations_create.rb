# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  up do
    create_table(:recommendations) do
      primary_key :id
      # foreign_key :song_id, :songs, null: false

      String     :title, null: false
      String     :artist_name_string, null: false
      Integer    :search_cnt, null: false
      String     :origin_id, null: false
      String     :cover_image_url_small
      Numeric    :language_difficulty, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:recommendations)
  end
end
