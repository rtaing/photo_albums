class AddPositionIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :albums, :position
    add_index :photos, :position
  end
end
