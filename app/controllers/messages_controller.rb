# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_message, only: %i[show edit update destroy]
  skip_before_action :require_login

  # GET /messages
  def index
    @messages = Message.all
  end

  # GET /messages/1
  def show
    id = @message.id
    # 集計
    collect_metrics(id)

    return if params['authenticity_token'].nil?

    ws = WebpushService.new
    # 一斉送信メッセージ設定
    ws.broadcast_message @message
    # Web プッシュ送信
    ws.webpush_clients

    # TODO: Metrics/AbcSize 対応せねば
    case [@message.status, params['status'].to_i]
    when [Message.status.un_send.value, Message.status.sent_test.value]
      # 未送信状態でテスト送信した場合
      @message.status = Message.status.sent_test.value
      @message.save
      redirect_to(message_path, notice: '[テストユーザ向け] WEBプッシュ送信しました')
      return
    when [Message.status.sent_test.value, Message.status.sent_real_user.value]
      # テスト送信済みでリアルユーザ送信した場合
      @message.status = Message.status.sent_real_user.value
      @message.save
      redirect_to(message_path, notice: '[リアルユーザ向け] WEBプッシュ送信しました')
      return
    end
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit; end

  # POST /messages
  def create
    @message = Message.new(message_params)

    if @message.save
      redirect_to @message, notice: 'Message was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /messages/1
  def update
    if @message.update(message_params)
      redirect_to @message, notice: 'Message was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /messages/1
  def destroy
    @message.destroy
    redirect_to messages_url, notice: 'Message was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def message_params
    params.fetch(:message, {})
    params.require(:message).permit(:title, :message, :link, :send_reservation_at, :status)
  end

  def collect_metrics(id)
    success_ids = redis.lrange "message/#{id}/success", 0, -1
    fail_ids = redis.lrange "message/#{id}/fail", 0, -1
    @success_ids_count = success_ids.uniq.length
    @fail_ids_count = fail_ids.uniq.length
  end
end
