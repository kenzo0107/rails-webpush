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
    # プッシュ通知送信結果 集計
    collect_metrics(id)

    # TODO: POST の判定はきっとこれじゃないと思うので、後々調整
    return if params['authenticity_token'].nil?

    # テストユーザ向け送信
    send_to_test_user if params['status'].to_i == Message.status.sent_test.value

    # テスト送信済みでリアルユーザ送信ボタン押下時のみ送信
    send_to_real_user if @message.status.sent_test? && params['status'].to_i == Message.status.sent_real_user.value
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

  def send_to_test_user
    # TODO: テストユーザ メアド 直指定をやめて別途テーブル管理したい。
    u = User.find_by(email: 'kenzo.tanaka@medpeer.co.jp')
    ws = WebpushService.new u.id
    # 一斉送信メッセージ設定
    ws.broadcast_message @message
    # Web プッシュ送信
    ws.webpush_clients

    return unless @message.status.un_send?

    @message.status = Message.status.sent_test.value
    @message.save
  end

  def send_to_real_user
    ws = WebpushService.new
    # 一斉送信メッセージ設定
    ws.broadcast_message @message
    # Web プッシュ送信
    ws.webpush_clients

    return unless @message.status.sent_test?

    @message.status = Message.status.sent_real_user.value
    @message.save
  end
end
