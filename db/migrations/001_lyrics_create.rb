# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  up do
    create_table(:lyrics) do
      primary_key :id

      String :text
      Bool :is_mandarin
      Bool :is_explicit

      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:lyrics)
  end
end
