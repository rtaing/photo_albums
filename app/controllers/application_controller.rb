class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  private
  
    def user_required
      redirect_to login_path unless current_user
    end
    
    def admin_required
      head(401) unless current_user && current_user.admin
    end
    
    def current_user
      if session[:user_id]
        @current_user ||= User.find(session[:user_id])
      end
    end
    
    helper_method :current_user
    
    def set_albums_path_as_back
      @back = albums_path
    end
end
