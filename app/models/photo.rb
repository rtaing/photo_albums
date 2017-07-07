class Photo < ApplicationRecord
  belongs_to :album
  has_one :album_cover, class_name: 'Album', foreign_key: 'cover_photo_id'
  acts_as_list scope: :album
  
  has_attached_file :picture, 
    styles: { web: "1200x1000>", thumb: "200x200#" }, 
    convert_options: {:slide => "-strip", :thumb => "-quality 50 -strip" }
  validates_attachment_presence :picture
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\z/
end
