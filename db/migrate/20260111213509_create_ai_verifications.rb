class CreateAiVerifications < ActiveRecord::Migration[7.2]
  def change
    create_table :ai_verifications do |t|
      t.references :listing, null: false, foreign_key: true
      t.integer :status
      t.decimal :confidence
      t.text :reason
      t.jsonb :raw_response

      t.timestamps
    end
  end
end
