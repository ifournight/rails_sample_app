class StaticPagesController < ApplicationController
  include ApplicationHelper
  def home
    show_current_user if logged_in?
  end

  def help
  end
  
  def about
  end

  def contact
  end
  
  def show_current_user(errors: nil)
    @user = current_user
    @micropost = @user.microposts.build
    deserialize_errors(@micropost.errors, flash[:micropost_errors]) if flash[:micropost_errors]
    flash.delete :micropost_errors
    @feed_microposts = @user.feed.paginate(page: params[:page])
  end
end
