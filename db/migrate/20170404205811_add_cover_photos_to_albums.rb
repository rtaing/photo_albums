class AddCoverPhotosToAlbums < ActiveRecord::Migration[5.0]
  def change
    add_column :albums, :cover_photo_id, :integer
  end
end
