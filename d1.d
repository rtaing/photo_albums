diff --git Gemfile Gemfile
index 3fe3c0b..a8ba18b 100644
--- Gemfile
+++ Gemfile
@@ -2,7 +2,6 @@ source 'http://rubygems.org'
 
 gem 'rails', '~> 5.1.1'
 
-
 # Use Puma as the app server
 gem 'puma', '~> 3.0'
 
diff --git app/controllers/albums_controller.rb app/controllers/albums_controller.rb
index 7e51c0f..aea8ca0 100644
--- app/controllers/albums_controller.rb
+++ app/controllers/albums_controller.rb
@@ -20,7 +20,7 @@ class AlbumsController < ApplicationController
   def create
     @album = Album.new(album_params)
     if @album.save
-      redirect_to @album, notice: 'Album was successfully created.'
+      redirect_to albums_path, notice: 'Album was successfully created.'
     else
       render :new
     end
@@ -28,7 +28,7 @@ class AlbumsController < ApplicationController
 
   def update
     if @album.update(album_params)
-      redirect_to @album, notice: 'Album was successfully updated.'
+      redirect_to albums_path, notice: 'Album was successfully updated.'
     else
       render :edit
     end
diff --git test/controllers/albums_controller_test.rb test/controllers/albums_controller_test.rb
index 1fdf2c9..b1cd28f 100644
--- test/controllers/albums_controller_test.rb
+++ test/controllers/albums_controller_test.rb
@@ -72,28 +72,7 @@ class AlbumsControllerTest < ActionDispatch::IntegrationTest
     assert_difference('Album.count') do
       post albums_url(album: { name: @album.name })
     end
-
-    assert_redirected_to album_url(Album.last)
-  end
-
-  test "should show album" do
-    sign_in_with("password")
-    get album_url(@album)
-    assert_response :success
-  end
-  
-  test "should not have edit and destroy links on show if not admin" do
-    sign_in_with("password")
-    get album_url(@album)
-    assert_select "a[href='#{edit_album_path(@album)}']", false
-    assert_select 'a', { text: 'Destroy', count: 0 }
-  end
-  
-  test "should have edit and destroy links on show if admin" do
-    sign_in_with("admin")
-    get album_url(@album)
-    assert_select "a[href='#{edit_album_path(@album)}']"
-    assert_select 'a', 'Destroy'
+    assert_redirected_to albums_url
   end
   
   test "should error on edit if not admin" do
@@ -117,7 +96,7 @@ class AlbumsControllerTest < ActionDispatch::IntegrationTest
   test "should update album if admin" do
     sign_in_with("admin")
     patch album_url(@album, album: { name: "New name" })
-    assert_redirected_to album_url(@album)
+    assert_redirected_to albums_url
   end
   
   test "should error on destroy if not admin" do
@@ -136,10 +115,10 @@ class AlbumsControllerTest < ActionDispatch::IntegrationTest
   
   test "should have link to add images to an album if admin" do
     sign_in_with("password")
-    get album_url(@album)
+    get album_photos_url(@album)
     assert_select "a[href='#{new_photos_album_path(@album)}']", false
     sign_in_with("admin")
-    get album_url(@album)
+    get album_photos_url(@album)
     assert_select "a[href='#{new_photos_album_path(@album)}']"
   end
     
