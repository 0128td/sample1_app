class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
  end

  def create
    @user = User.new(name: params[:name], email: params[:email], password: params[:password])
    if @user.save
      flash[:notice] = I18n.t("helpers.submit.create")
      redirect_to("/users/index")
    else
      flash[:notice] = I18n.t("helpers.submit.update")
      render("users/new")
    end
  end

  def update
  end

  def destroy
    @user = User.find_by(confirmation_token: params[:id])

    @user.destroy
    flash[:notice] = I18n.t("helpers.submit.destroy")
    redirect_to("/users/index")
  end
end
