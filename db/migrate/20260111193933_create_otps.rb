class CreateOtps < ActiveRecord::Migration[7.2]
  def change
    create_table :otps do |t|
      t.references :user, null: false, foreign_key: true
      t.string :purpose
      t.string :code_digest
      t.datetime :expires_at
      t.datetime :used_at

      t.timestamps
    end
  end
end
