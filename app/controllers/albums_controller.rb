class AlbumsController < ApplicationController
  before_action :user_required
  before_action :admin_required, except: [:index, :show]
  before_action :set_album, only: [:show, :edit, :update, :destroy, :update_cover_photo, :new_photos, :create_photos]
  before_action :set_albums_path_as_back, only: [:show, :new, :edit]
  
  def index
    @title = 'Albums'
    @albums = Album.sorted
  end

  def new
    @title = 'New Album'
    @album = Album.new
  end

  def edit
  end

  def create
    @album = Album.new(album_params)
    if @album.save
      redirect_to albums_path, notice: 'Album was successfully created.'
    else
      render :new
    end
  end

  def update
    if @album.update(album_params)
      redirect_to albums_path, notice: 'Album was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @album.destroy
    redirect_to albums_url, notice: 'Album was successfully destroyed.'
  end
  
  def update_photo_position
    photo = Photo.find_by_id(params[:photo_id])
    new_index = params[:new_index]
    if photo && new_index.present?
      new_position = photo.album.photo_position_at_index(new_index.to_i)
      begin
        photo.insert_at(new_position)
        head :ok
        return
      rescue
      end
    end
    render :unprocessable_entity
  end
  
  def update_cover_photo
    photo = Photo.find_by_id(params[:photo_id])
    if photo.present?
      @album.cover_photo = photo
      if @album.save
        render json: {}, status: :ok
        return
      end
    end    
    render :unprocessable_entity
  end
  
  def new_photos
    @back = album_photos_path(@album)
  end
  
  def create_photos
    if params[:pictures].present?
      begin
        params[:pictures].each do |picture|
          @album.photos.create(picture: picture)
        end
        redirect_to album_photos_path(@album), notice: 'Photos added successfully'
      rescue Exception => e
        logger.info "Exception during create_photos: #{e.inspect}"
        render :new_photos, notice: 'Something went wrong during photo creation'
      end
    else
      render :new_photos, notice: 'You must select photos to upload'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_album
      @album = Album.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def album_params
      params.require(:album).permit(:name)
    end
end
