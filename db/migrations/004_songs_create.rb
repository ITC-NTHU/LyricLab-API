# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  up do
    create_table(:songs) do
      primary_key :id
      foreign_key :lyrics_id, :lyrics
      foreign_key :vocabulary_id, :vocabularies

      String     :title, null: false
      String     :origin_id, null: false
      Integer    :popularity, null: false
      String     :preview_url
      String     :album_name, null: false
      String     :artist_name_string, null: false
      String     :cover_image_url_big
      String     :cover_image_url_medium
      String     :cover_image_url_small
      Integer    :search_counter, null: false, default: 0
      Boolean    :is_instrumental

      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:songs)
  end
end
