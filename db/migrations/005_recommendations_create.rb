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
      String     :spotify_id, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:recommendations)
  end
end
