require "application_system_test_case"

class PhotosTest < ApplicationSystemTestCase
  
  test "upload photos" do
    login_and_visit albums_path
    
    click_link 'No Photos', match: :first
    assert_no_selector 'img.img-gallery'
    
    sleep 1
    click_on 'New'
    attach_file 'pictures[]', "test/fixtures/files/sunscreen_1.jpg"
    click_on 'Upload'
    assert_selector 'img.img-gallery'
    
    click_on 'New'
    attach_file 'pictures[]', ["test/fixtures/files/sunscreen_2.jpg", "test/fixtures/files/sunscreen_3.jpg"]
    click_on 'Upload'
    assert_selector 'img.img-gallery', count: 3
  end

  test "download photos" do
    visit_multiple_photos_album
    
    find("#photo_link_#{@photo.id}").trigger('click')
    click_on 'Download full size'
    sleep 1
    assert response_headers['Content-Type'], 'image/jpeg'
  end
  
  test "navigate photos" do
    visit_multiple_photos_album
    
    album_photos_size = @album.photos.size
    
    find("#photo_link_#{@photo.id}").click
    assert_selector '.mfp-counter', text: "1 of #{album_photos_size}"

    click_on 'Next'
    assert_selector '.mfp-counter', text: "2 of #{album_photos_size}"
    
    click_on 'Previous'
    assert_selector '.mfp-counter', text: "1 of #{album_photos_size}"
    
    click_on 'Previous'
    assert_selector '.mfp-counter', text: "#{album_photos_size} of #{album_photos_size}"
    
    click_on 'Next'
    assert_selector '.mfp-counter', text: "1 of #{album_photos_size}"
  end

  test "add a description" do
    visit_multiple_photos_album
    
    find("#photo_edit_#{@photo.id}").trigger('click')
    assert_current_path edit_photo_path(@photo)
    
    fill_in :photo_description, with: 'The description'
    click_on 'Update'
    
    find("#photo_link_#{@photo.id}").trigger('click')
    assert_text 'The description'
  end
  
  test "delete photo" do
    visit_multiple_photos_album
    
    assert_selector "#photo_link_#{@photo.id}"
    find("#photo_delete_#{@photo.id}").trigger('click')
    assert_no_selector "#photo_link_#{@photo.id}"
  end
  
  private
  
    def visit_multiple_photos_album
      login_and_visit albums_path
    
      @album = albums(:album_with_multiple_photos)
      @photo = @album.photos.first
      click_on @album.name
    end
  
end
