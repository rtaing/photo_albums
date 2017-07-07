require 'test_helper'

class PhotosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @album = albums(:album_with_multiple_photos)
    @non_cover_photo = photos(:first_photo_in_multiple_photos_album)
    @photo = photos(:second_photo_in_multiple_photos_album)
  end
  
  teardown do
    remove_attachments
  end

  test "should get index" do
    get album_photos_url(@album)
    assert_redirected_to login_url
    sign_in_with("password")
    get album_photos_url(@album)
    assert_response :success
  end
  
  test "should show all photos in the album" do
    add_attachments
    sign_in_with("password")
    get album_photos_url(@album)
    @album.photos.each do |photo|
      assert_select "img[src='#{photo.picture.url(:thumb)}']"
    end
  end
  
  test "should show sorted photos" do
    add_attachments
    sign_in_with("password")
    get album_photos_url(@album)
    sorted_positions = @album.photos.map(&:position).sort
    actual_positions = css_select("img.img-gallery").map{|img| img["data-position"].to_i}
    assert_equal sorted_positions, actual_positions
  end
  
  test "index should restrict admin links" do
    sign_in_with("password")
    get album_photos_url(@album)
    assert_select "a[href='#{new_photos_album_path(@album)}']", false
    sign_in_with("admin")
    get album_photos_url(@album)
    assert_select "a[href='#{new_photos_album_path(@album)}']"
  end

  test "should get edit" do
    @photo.update_attribute(:picture, fixture_file_upload('test/fixtures/files/sunscreen_1.jpg', 'image/jpeg'))
    get edit_photo_url(@photo)
    assert_redirected_to login_url
    sign_in_with("password")
    get edit_photo_url(@photo)
    assert_response 401
    sign_in_with("admin")
    get edit_photo_url(@photo)
    assert_response :success
    assert_select "img[src='#{@photo.picture.url(:web)}']"
  end

  test "should update photo" do
    patch photo_url(@photo, photo: { album_id: @photo.album_id, description: "New description", position: @photo.position })
    assert_redirected_to login_url
    sign_in_with("password")
    patch photo_url(@photo, photo: { album_id: @photo.album_id, description: "New description", position: @photo.position })
    assert_response 401
    sign_in_with("admin")
    uploaded = fixture_file_upload('test/fixtures/files/sunscreen_1.jpg', 'image/jpeg')
    patch photo_url(@photo), params: { photo: { album_id: @photo.album_id, description: "New description", position: @photo.position, picture: uploaded } }
    
    assert_redirected_to album_photos_url(@photo.album)
  end

  test "should destroy photo" do
    delete photo_url(@photo)
    assert_redirected_to login_url
    sign_in_with("password")
    delete photo_url(@photo)
    assert_response 401
    sign_in_with("admin")
    assert_difference('Photo.count', -1) do
      delete photo_url(@photo)
    end

    assert_redirected_to album_photos_url(@album)
  end
  
  test "should redirect to full size photo download" do
    get download_photo_url(@photo)
    assert_redirected_to login_url
    sign_in_with("password")
    get download_photo_url(@photo)
    assert_redirected_to @photo.picture.url
  end
  
  test "should have link to go back to album list" do
    sign_in_with("password")
    get album_photos_url(@album)
    assert_select "a[href='#{albums_path}']"
  end
  
  test "should have link to set photo as album cover" do
    sign_in_with("admin")
    get album_photos_url(@album)
    assert_select "a[href='#{update_cover_photo_album_path(@album)}'][data-params='photo_id=#{@non_cover_photo.id}']"
  end
  
  test "should not have link to set cover photo for current cover photo" do
    sign_in_with("admin")
    get album_photos_url(@album)
    assert_equal @album.cover_photo, @photo
    assert_select "a[href='#{update_cover_photo_album_path(@album)}'][data-params='photo_id=#{@photo.id}']", false
  end
  
end
