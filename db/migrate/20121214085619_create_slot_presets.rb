class CreateSlotPresets < ActiveRecord::Migration
  def change
    create_table :slot_presets do |t|
      t.integer :slot_id
      t.integer :preset_id
      t.references :transcoder

      t.timestamps
    end
  end
end
