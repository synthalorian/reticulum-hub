# frozen_string_literal: true

class MessagesController < ApplicationController
  def index
    @messages = Message.order(sent_at: :desc).limit(50)
    @conversations = @messages.group_by(&:conversation_key)
  end

  def show
    @message = Message.find(params[:id])
  end

  def new
    @message = Message.new(direction: "outbound")
    @peers = Peer.active.pluck(:name, :destination_hash)
  end

  def create
    @message = Message.new(message_params.merge(direction: "outbound", sent_at: Time.current, sender_hash: "<local>"))

    if @message.save
      # Attempt to send via RNS
      rns = RnsAdapter.new
      rns.connect
      rns.send_lxmf(@message.recipient_hash, @message.subject, @message.body)

      redirect_to messages_path, notice: "Message sent."
    else
      @peers = Peer.active.pluck(:name, :destination_hash)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:recipient_hash, :subject, :body)
  end
end
