class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :verify_user, only: :destroy
  include ApplicationHelper
  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = 'Micropost created!'
      redirect_to root_url
    else
      @feed_microposts = current_user.feed.paginate(page: 1)
      flash[:micropost_errors] = serialize_errors @micropost.errors
      redirect_to root_url
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = 'Micropost deleted!'
    redirect_to request.referer || root_url
  end

  private
  def micropost_params
    params.require(:micropost).permit(:content, :picture)
  end

  def verify_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url if @micropost.nil?
  end
end
