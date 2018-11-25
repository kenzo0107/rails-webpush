# frozen_string_literal: true

class UserSessionsController < ApplicationController
  skip_before_action :require_login, except: [:destroy]

  def new
    @user = User.new
  end

  def create
    @user = login(params[:email], params[:password])
    if @user.present?
      redirect_back_or_to(:users, notice: 'ログイン成功しました')
    else
      flash.now[:alert] = 'ログイン失敗しました'
      render action: 'new'
    end
  end

  def destroy
    logout
    redirect_to(:users, notice: 'Logged out!')
  end
end
