diff --git app/controllers/albums_controller.rb app/controllers/albums_controller.rb
index aea8ca0..5fb8a71 100644
--- app/controllers/albums_controller.rb
+++ app/controllers/albums_controller.rb
@@ -41,10 +41,11 @@ class AlbumsController < ApplicationController
   
   def update_photo_position
     photo = Photo.find_by_id(params[:photo_id])
-    new_position = params[:new_position]
-    if photo && new_position.present?
+    new_index = params[:new_index]
+    if photo && new_index.present?
+      new_position = photo.album.photo_position_at_index(new_index.to_i)
       begin
-        photo.insert_at(new_position.to_i)
+        photo.insert_at(new_position)
         head :ok
         return
       rescue
diff --git app/models/album.rb app/models/album.rb
index 1cea03a..7673505 100644
--- app/models/album.rb
+++ app/models/album.rb
@@ -9,4 +9,8 @@ class Album < ApplicationRecord
   def photo_count
     self.photos.count
   end
+  
+  def photo_position_at_index(index)
+    self.photos[index] ? self.photos[index].position : 0
+  end
 end
diff --git app/views/photos/index.html.erb app/views/photos/index.html.erb
index 48d6ef6..1c2fa56 100644
--- app/views/photos/index.html.erb
+++ app/views/photos/index.html.erb
@@ -7,7 +7,7 @@
           <%= image_tag photo.picture.url(:thumb), class: 'img-responsive img-gallery' %>
         <% end %>
         <% if current_user.admin %>
-          <% if photo.album_cover.present? %>
+          <% if @album.cover_photo == photo %>
             <span class="glyphicon glyphicon-star"></span>
           <% else %>
             <%= link_to '<span class="glyphicon glyphicon-star-empty"></span>'.html_safe, update_cover_photo_album_path(@album), class: 'cover_photo_link', remote: true, method: :patch, data: { params: {photo_id: photo.id}.to_param } %>
@@ -49,7 +49,7 @@
       sortableList = document.getElementById('sortableList');      
       Sortable.create(sortableList, {
         onUpdate: function(evt){
-          $.post('<%= album_update_photo_position_path(@album) %>', {photo_id: evt.item.dataset.id, new_position: evt.newIndex + 1}).fail(function(){
+          $.post('<%= album_update_photo_position_path(@album) %>', {photo_id: evt.item.dataset.id, new_index: evt.newIndex}).fail(function(){
             alert('Error updating photo position');
           });
         }
diff --git test/controllers/albums_controller_test.rb test/controllers/albums_controller_test.rb
index b1cd28f..55d50a2 100644
--- test/controllers/albums_controller_test.rb
+++ test/controllers/albums_controller_test.rb
@@ -131,7 +131,7 @@ class AlbumsControllerTest < ActionDispatch::IntegrationTest
     @second_photo_in_album.picture = uploaded
     @second_photo_in_album.save
 
-    post album_update_photo_position_url(@album, photo_id: @second_photo_in_album.id, new_position: 1)
+    post album_update_photo_position_url(@album, photo_id: @second_photo_in_album.id, new_index: 0)
     assert :success
     @second_photo_in_album.reload
     @first_photo_in_album.reload
