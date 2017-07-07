require "application_system_test_case"

class AlbumsTest < ApplicationSystemTestCase
  
  test "create albums" do
    login_and_visit albums_path
    assert_no_text 'Created Album'
    
    click_on 'New'
    fill_in :album_name, with: 'Created Album'
    click_on 'Create'
    assert_text 'Created Album'
  end
  
  test "edit album" do
    login_and_visit albums_path
    
    album = albums(:album_with_multiple_photos)
    find("#album_edit_#{album.id}").trigger('click')
    assert_current_path edit_album_path(album)
    assert find_field(:album_position).value, '2'
    
    fill_in :album_name, with: 'Updated Name'
    fill_in :album_position, with: '3'
    click_on 'Update'
    assert_text 'Album was successfully updated.'
    
    find("#album_edit_#{album.id}").trigger('click')
    assert find_field(:album_position).value, '3'
  end
  
  test "delete album" do
    login_and_visit albums_path

    album = albums(:album_with_multiple_photos)
    assert_text album.name
    
    find("#album_delete_#{album.id}").trigger('click')
    assert_no_text album.name
  end
  
end
