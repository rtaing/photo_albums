class AddPositionToAlbums < ActiveRecord::Migration[5.1]
  def change
    add_column :albums, :position, :integer
    Album.order(:id).each.with_index(1) do |item, index|
      item.update_column :position, index
    end
  end
end
