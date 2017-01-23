class AccountActivationsController < ApplicationController
    def edit
        user = User.find_by(email: params[:email])
        if user && !user.activated?  && user.autheticate?(:activation, params[:id])
            user.activate
            log_in user
            flash[:success] = "Acount activated!"
            redirect_to user
        else
            flash[:danger] = "Invalide activation link!"
            redirect_to root_url
        end
    end
end
