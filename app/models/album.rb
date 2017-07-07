class Album < ApplicationRecord
  has_many :photos, -> { order(position: :asc) }
  belongs_to :cover_photo, class_name: 'Photo', optional: true
  scope :sorted, -> { order(position: :asc) }
  acts_as_list

  def cover_photo_url
    cover_photo.present? ? cover_photo.picture.url(:thumb) : (self.photos.exists? ? self.photos.first.picture.url(:thumb) : '')
  end
  
  def photo_count
    self.photos.count
  end
  
  def photo_position_at_index(index)
    self.photos[index] ? self.photos[index].position : 0
  end
end
