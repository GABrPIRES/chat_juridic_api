class ChatChannel < ApplicationCable::Channel
    def subscribed
      @chat = Chat.find(params[:chat_id])
      stream_from "chats:#{@chat.id}" # <- nome do stream
    end
  end
  