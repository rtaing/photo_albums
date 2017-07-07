diff --git app/controllers/albums_controller.rb app/controllers/albums_controller.rb
index 5fb8a71..46d4f30 100644
--- app/controllers/albums_controller.rb
+++ app/controllers/albums_controller.rb
@@ -6,7 +6,7 @@ class AlbumsController < ApplicationController
   
   def index
     @title = 'Albums'
-    @albums = Album.all
+    @albums = Album.sorted
   end
 
   def new
diff --git app/models/album.rb app/models/album.rb
index 7673505..b592309 100644
--- app/models/album.rb
+++ app/models/album.rb
@@ -1,6 +1,8 @@
 class Album < ApplicationRecord
   has_many :photos, -> { order(position: :asc) }
   belongs_to :cover_photo, class_name: 'Photo', optional: true
+  scope :sorted, -> { order(position: :asc) }
+  acts_as_list
 
   def cover_photo_url
     cover_photo.present? ? cover_photo.picture.url(:thumb) : (self.photos.exists? ? self.photos.first.picture.url(:thumb) : '')
diff --git app/views/albums/_form.html.erb app/views/albums/_form.html.erb
index 7a10056..562831a 100644
--- app/views/albums/_form.html.erb
+++ app/views/albums/_form.html.erb
@@ -16,6 +16,11 @@
     <%= f.text_field :name %>
   </div>
 
+  <div class="field form-group">
+    <%= f.label :position %>
+    <%= f.text_field :position %>
+  </div>
+
   <div class="actions">
     <%= f.submit class: 'btn btn-info' %>
   </div>
diff --git app/views/albums/index.html.erb app/views/albums/index.html.erb
index 646ed55..764765d 100644
--- app/views/albums/index.html.erb
+++ app/views/albums/index.html.erb
@@ -1,7 +1,7 @@
 <div class="row row-padding">
   <% @albums.each do |album| %>
     <div class="col-xs-6 col-sm-4 col-md-2 col-padding text-center">
-      <%= link_to album_photos_path(album) do %>
+      <%= link_to album_photos_path(album), class: 'album', data: { position: album.position } do %>
         <% if album.cover_photo_url.present? %>
           <%= image_tag album.cover_photo_url, class: 'img img-responsive center-block img-gallery' %>
         <% else %>
@@ -11,7 +11,7 @@
       <span>
         <%= link_to album.name, album_photos_path(album) %>
         <% if current_user.admin %> | 
-          <%= link_to 'Edit', edit_album_path(album) %> | 
+          <%= link_to 'Edit', edit_album_path(album), id: "album_edit_#{album.id}" %> | 
           <%= link_to 'Destroy', album, method: :delete, id: "album_delete_#{album.id}", data: { confirm: 'Are you sure?' } %>
         <% end %>
       </span>
diff --git app/views/photos/index.html.erb app/views/photos/index.html.erb
index 1c2fa56..e07485d 100644
--- app/views/photos/index.html.erb
+++ app/views/photos/index.html.erb
@@ -4,7 +4,7 @@
     <% photo_group.each do |photo| %>
       <div class="col-xs-3 col-sm-2 col-md-1 col-padding row-padding" data-id="<%= photo.id %>">
         <%= link_to photo.picture.url(:web), class: 'gallery', title: photo.description.to_s, full: download_photo_path(photo), id: "photo_link_#{photo.id}" do %>
-          <%= image_tag photo.picture.url(:thumb), class: 'img-responsive img-gallery' %>
+          <%= image_tag photo.picture.url(:thumb), class: 'img-responsive img-gallery', data: { position: photo.position }  %>
         <% end %>
         <% if current_user.admin %>
           <% if @album.cover_photo == photo %>
diff --git db/schema.rb db/schema.rb
index f976dd0..e71e95e 100644
--- db/schema.rb
+++ db/schema.rb
@@ -10,13 +10,15 @@
 #
 # It's strongly recommended that you check this file into your version control system.
 
-ActiveRecord::Schema.define(version: 20170404205811) do
+ActiveRecord::Schema.define(version: 20170705225627) do
 
   create_table "albums", force: :cascade do |t|
     t.string "name"
     t.datetime "created_at", null: false
     t.datetime "updated_at", null: false
     t.integer "cover_photo_id"
+    t.integer "position"
+    t.index ["position"], name: "index_albums_on_position"
   end
 
   create_table "photos", force: :cascade do |t|
@@ -30,6 +32,7 @@ ActiveRecord::Schema.define(version: 20170404205811) do
     t.integer "picture_file_size"
     t.datetime "picture_updated_at"
     t.index ["album_id"], name: "index_photos_on_album_id"
+    t.index ["position"], name: "index_photos_on_position"
   end
 
   create_table "users", force: :cascade do |t|
diff --git test/controllers/albums_controller_test.rb test/controllers/albums_controller_test.rb
index 55d50a2..1ae2bda 100644
--- test/controllers/albums_controller_test.rb
+++ test/controllers/albums_controller_test.rb
@@ -26,6 +26,14 @@ class AlbumsControllerTest < ActionDispatch::IntegrationTest
     assert_select "a[href='#{album_photos_path(@album)}']"
     assert_select "a[href='#{album_photos_path(@album_two)}']"
   end
+  
+  test "should show sorted albums" do
+    sign_in_with("password")
+    get albums_url
+    sorted_positions = Album.sorted.map(&:position)
+    actual_positions = css_select('a.album').map{|link| link["data-position"].to_i}
+    assert_equal sorted_positions, actual_positions
+  end
     
   test "should not have links to create or edit albums if not admin" do
     sign_in_with("password")
@@ -95,7 +103,7 @@ class AlbumsControllerTest < ActionDispatch::IntegrationTest
 
   test "should update album if admin" do
     sign_in_with("admin")
-    patch album_url(@album, album: { name: "New name" })
+    patch album_url(@album, album: { name: "New name", position: 2 })
     assert_redirected_to albums_url
   end
   
diff --git test/controllers/photos_controller_test.rb test/controllers/photos_controller_test.rb
index b23fd53..3544586 100644
--- test/controllers/photos_controller_test.rb
+++ test/controllers/photos_controller_test.rb
@@ -28,6 +28,15 @@ class PhotosControllerTest < ActionDispatch::IntegrationTest
     end
   end
   
+  test "should show sorted photos" do
+    add_attachments
+    sign_in_with("password")
+    get album_photos_url(@album)
+    sorted_positions = @album.photos.map(&:position).sort
+    actual_positions = css_select("img.img-gallery").map{|img| img["data-position"].to_i}
+    assert_equal sorted_positions, actual_positions
+  end
+  
   test "index should restrict admin links" do
     sign_in_with("password")
     get album_photos_url(@album)
diff --git test/fixtures/albums.yml test/fixtures/albums.yml
index 88c3e95..c22f3f1 100644
--- test/fixtures/albums.yml
+++ test/fixtures/albums.yml
@@ -1,9 +1,12 @@
 album_with_no_photos:
   name: No Photos
+  position: 1
   
 album_with_multiple_photos:
   name: Multiple Photos
   cover_photo: second_photo_in_multiple_photos_album
+  position: 2
 
 album_with_one_photo:
   name: Only One Photo
+  position: 3
diff --git test/system/albums_test.rb test/system/albums_test.rb
index 2550dfd..8f4cfaf 100644
--- test/system/albums_test.rb
+++ test/system/albums_test.rb
@@ -12,6 +12,23 @@ class AlbumsTest < ApplicationSystemTestCase
     assert_text 'Created Album'
   end
   
+  test "edit album" do
+    login_and_visit albums_path
+    
+    album = albums(:album_with_multiple_photos)
+    find("#album_edit_#{album.id}").trigger('click')
+    assert_current_path edit_album_path(album)
+    assert find_field(:album_position).value, '2'
+    
+    fill_in :album_name, with: 'Updated Name'
+    fill_in :album_position, with: '3'
+    click_on 'Update'
+    assert_text 'Album was successfully updated.'
+    
+    find("#album_edit_#{album.id}").trigger('click')
+    assert find_field(:album_position).value, '3'
+  end
+  
   test "delete album" do
     login_and_visit albums_path
 
