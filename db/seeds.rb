# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

if Rails.env == 'development'  
  User.create_custom('admin', true)
  User.create_custom('password')
  album = Album.create({ name: 'Animals' })
  1.upto(14) do |i|
    album.photos.create({ picture: File.new("db/seed_images/animal#{i}.jpg"), album:album })
  end
  album = Album.create({ name: 'Food' })
  1.upto(4) do |i|
    album.photos.create({ picture: File.new("db/seed_images/food#{i}.jpg"), album:album })
  end
end