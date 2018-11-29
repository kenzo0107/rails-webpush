class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  skip_before_action :require_login

  # GET /messages
  def index
    @messages = Message.all
  end

  # GET /messages/1
  def show
    success_ids = redis.lrange "message/#{params[:id]}/success", 0, -1
    fail_ids = redis.lrange "message/#{params[:id]}/fail", 0, -1
    success_ids = success_ids.uniq
    fail_ids = fail_ids.uniq

    @success_ids_count = success_ids.uniq.length
    @fail_ids_count = fail_ids.uniq.length

    id = params['id']
    if params['authenticity_token']
      m = Message.find(id)
      ws = WebpushService.new
      ws.set_message_id m.id
      ws.set_title m.title
      ws.set_message m.message
      ws.set_link m.link
      ws.webpush_clients

      if m.status.un_send? && params['status'].to_i == Message.status.sent_test.value
        m.status = Message.status.sent_test.value
        m.save
        redirect_to(message_path, notice: '[テストユーザ向け] WEBプッシュ送信しました')
      end

      if m.status.sent_test? && params['status'].to_i == Message.status.sent_real_user.value
        m.status = Message.status.sent_real_user.value
        m.save
        redirect_to(message_path, notice: '[リアルユーザ向け] WEBプッシュ送信しました')
      end
    end
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

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
end
