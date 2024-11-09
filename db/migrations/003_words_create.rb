# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  up do
    create_table(:words) do
      primary_key :id

      String     :characters, null: false
      String     :translation, null: false
      String     :pinyin, null: false
      String     :difficulty
      String     :definition
      String     :word_type
      String     :example_sentence

      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:words)
  end
end
