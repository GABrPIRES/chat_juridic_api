module ApplicationCable
    class Connection < ActionCable::Connection::Base
      identified_by :current_user, :current_client
  
      def connect
        token = request.params['token']
        reject_unauthorized_connection unless token
  
        # Tenta decodificar como User
        decoded_user = JwtService.decode(token)
        if decoded_user && decoded_user["user_id"]
          @current_user = User.find_by(id: decoded_user["user_id"])
          return if @current_user
        end
  
        # Se não for User, tenta decodificar como Client
        decoded_client = JwtClientService.decode(token)
        if decoded_client && decoded_client["client_id"]
          @current_client = Client.find_by(id: decoded_client["client_id"])
          return if @current_client
        end
  
        # Se nenhum dos dois for válido, rejeita a conexão
        reject_unauthorized_connection
      end
    end
  end