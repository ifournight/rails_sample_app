# Responsible for user's password reset
class PasswordResetsController < ApplicationController
  before_action :user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new 
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_passwordreset_email
      flash[:success] = 'Password reset email already sent, please check your email inbox.'
      redirect_to root_url
    else
      flash[:danger] = 'Invalid email address'
      render 'new'
    end
  end

  def edit
  end

  def update
    if user_params[:password].empty?
      @user.errors.add(:password, "can't be empty.")
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = 'Password has be reset.'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    redirect_to root_url unless @user && @user.activated? && @user.autheticate?(:reset, params[:id])
  end

  def check_expiration
    if @user.password_reset_expire?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end
end
