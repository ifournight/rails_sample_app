class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page
      if params[:session][:remember_me] == '1'
        remember user
      else
        forget user
      end
      log_in user
      redirect_to user
    else
      flash.now[:danger] = "Invalid email/password combination" # Hard code!
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
