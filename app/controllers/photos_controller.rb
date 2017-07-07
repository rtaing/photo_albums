class PhotosController < ApplicationController
  before_action :user_required
  before_action :admin_required, except: [:index, :show, :download]
  before_action :set_album
  before_action :set_photo, only: [:show, :edit, :update, :destroy, :download]
  before_action :set_albums_path_as_back, only: [:index]
  before_action :set_photos_as_back, only: [:show, :edit]

  def index
    @title = @album ? @album.name : ''
    @photos = @album.photos
  end

  def edit
    @title = 'Editing Photo'
  end

  def update
    album = @photo.album
    if @photo.update(photo_params)
      redirect_to album_photos_path(album), notice: 'Photo was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    album = @photo.album
    @photo.destroy
    redirect_to album_photos_url(album), notice: 'Photo was successfully destroyed.'
  end
  
  def download
    redirect_to @photo.picture.url
  end

  private
    def set_photo
      @photo = Photo.find(params[:id])
    end
    
    def set_album
      @album = Album.find(params[:album_id]) if params[:album_id].present?
    end

    def photo_params
      params.require(:photo).permit(:description, :position, :picture)
    end
    
    def set_photos_as_back
      @back = album_photos_path(@photo.album)
    end
end
