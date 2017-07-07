require 'test_helper'

class AlbumsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @album = albums(:album_with_multiple_photos)
    @album_two = albums(:album_with_one_photo)
    @album_with_no_photos = albums(:album_with_no_photos)
    @first_photo_in_album = photos(:first_photo_in_multiple_photos_album)
    @second_photo_in_album = photos(:second_photo_in_multiple_photos_album)
  end
  
  teardown do
    remove_attachments
  end
  
  test "all should redirect to login if not logged in" do
    get albums_url
    assert_redirected_to login_url
  end

  test "should get all albums" do
    sign_in_with("password")
    get albums_url
    assert assigns[:albums]
    assert_equal assigns[:albums].count, Album.count
    assert_select "a[href='#{album_photos_path(@album)}']"
    assert_select "a[href='#{album_photos_path(@album_two)}']"
  end
  
  test "should show sorted albums" do
    sign_in_with("password")
    get albums_url
    sorted_positions = Album.sorted.map(&:position)
    actual_positions = css_select('a.album').map{|link| link["data-position"].to_i}
    assert_equal sorted_positions, actual_positions
  end
    
  test "should not have links to create or edit albums if not admin" do
    sign_in_with("password")
    get albums_url
    assert_select "a[href='#{new_album_path}']", false
    assert_select "a[href='#{edit_album_path(@album)}']", false
    assert_select "a", { text: "Destroy", count: 0 }
  end
  
  test "should have links to create or edit albums if admin" do
    sign_in_with("admin")
    get albums_url
    assert_select "a[href='#{new_album_path}']"
    assert_select "a[href='#{edit_album_path(@album)}']"
    assert_select "a", "Destroy"
  end
  
  test "should have logout links when logged in" do
    sign_in_with("password")
    get albums_url
    assert_select "a[href='#{logout_path}']"
  end

  test "should error on new if not admin" do
    sign_in_with("password")
    get new_album_url
    assert_response 401
  end
  
  test "should get new if admin" do
    sign_in_with("admin")
    get new_album_url
    assert_response :success
  end
  
  test "should error on create if not admin" do
    sign_in_with("password")
    post albums_url(album: { name: @album.name })
    assert_response 401
  end

  test "should create album" do
    sign_in_with("admin")
    assert_difference('Album.count') do
      post albums_url(album: { name: @album.name })
    end
    assert_redirected_to albums_url
  end
  
  test "should error on edit if not admin" do
    sign_in_with("password")
    get edit_album_url(@album)
    assert_response 401
  end

  test "should get edit" do
    sign_in_with("admin")
    get edit_album_url(@album)
    assert_response :success
  end
  
  test "should error on update if not admin" do
    sign_in_with("password")
    patch album_url(@album, album: { name: "New name"})
    assert_response 401
  end

  test "should update album if admin" do
    sign_in_with("admin")
    patch album_url(@album, album: { name: "New name", position: 2 })
    assert_redirected_to albums_url
  end
  
  test "should error on destroy if not admin" do
    sign_in_with("password")
    delete album_url(@album)
    assert_response 401
  end

  test "should destroy album if admin" do
    sign_in_with("admin")
    assert_difference('Album.count', -1) do
      delete album_url(@album)
    end
    assert_redirected_to albums_url
  end
  
  test "should have link to add images to an album if admin" do
    sign_in_with("password")
    get album_photos_url(@album)
    assert_select "a[href='#{new_photos_album_path(@album)}']", false
    sign_in_with("admin")
    get album_photos_url(@album)
    assert_select "a[href='#{new_photos_album_path(@album)}']"
  end
    
  test "should update photo position when dropped into new position" do
    sign_in_with("admin")

    uploaded = fixture_file_upload('test/fixtures/files/sunscreen_1.jpg', 'image/jpeg')
    @first_photo_in_album.picture = uploaded
    @first_photo_in_album.save
    @second_photo_in_album.picture = uploaded
    @second_photo_in_album.save

    post album_update_photo_position_url(@album, photo_id: @second_photo_in_album.id, new_index: 0)
    assert :success
    @second_photo_in_album.reload
    @first_photo_in_album.reload
    
    assert_equal @second_photo_in_album.position, 1
    assert_equal @first_photo_in_album.position, 2
  end
    
  test "should set cover photo" do
    sign_in_with("admin")
    patch update_cover_photo_album_url(@album, photo_id: @second_photo_in_album.id)
    assert :success
    @album.reload
    assert_equal @album.cover_photo, @second_photo_in_album
  end
  
  test "should show cover photo default photo or album name" do
    add_attachments
    sign_in_with("password")
    get albums_url
    assert_select "img[src='#{@album.cover_photo_url}']"
    assert_select "img[src='#{@album_two.cover_photo_url}']"
    assert_select "a", text: /#{@album_with_no_photos.name}/
  end

  test "should get new photos form" do
    get new_photos_album_url(@album)
    assert_redirected_to login_url
    sign_in_with("password")
    get new_photos_album_url(@album)
    assert_response 401
    sign_in_with("admin")
    get new_photos_album_url(@album)
    assert_response :success
    assert_select "input[type='file']"
  end

  test "should create photos" do
    get album_photos_url(@album)
    assert_redirected_to login_url
    sign_in_with("password")
    get album_photos_url(@album)
    assert :failure
    sign_in_with("admin")
    uploaded = []
    uploaded << fixture_file_upload('test/fixtures/files/sunscreen_1.jpg', 'image/jpeg')
    uploaded << fixture_file_upload('test/fixtures/files/sunscreen_2.jpg', 'image/jpeg')
    assert_difference('Photo.count', 2) do
      post create_photos_album_url(@album), params: { pictures: uploaded }
    end
    assert_redirected_to album_photos_url(@album)
  end
  
end
