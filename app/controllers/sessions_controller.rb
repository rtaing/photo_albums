class SessionsController < ApplicationController
  
  def new
  end
  
  def create
    user = User.find_with_password(params[:password])
    if user
      session[:user_id] = user.id
      redirect_to albums_path
    else
      flash[:error] = ["GUESS AGAIN!", "NOPE", "NOT EVEN CLOSE", "GIVE UP?", "GETTING WARMER", "GETTING COLDER", "HAHAHA", ":P", ":("].sample 
      redirect_to login_path
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to login_path
  end
  
end
