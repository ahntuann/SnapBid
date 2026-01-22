class CreateSystemSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :system_settings do |t|
      t.decimal :ai_threshold
      t.decimal :commission_percent
      t.decimal :min_bid_step

      t.timestamps
    end
  end
end
