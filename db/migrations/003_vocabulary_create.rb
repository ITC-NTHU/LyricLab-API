# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  up do
    create_table(:vocabularies) do
      primary_key :id

      String :sep_text
      String :raw_text
      Numeric :language_difficulty, default: -1

      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:vocabularies)
  end
end
