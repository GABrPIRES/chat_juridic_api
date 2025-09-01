module ApplicationCable
    class Connection < ActionCable::Connection::Base
      identified_by :current_user, :current_client
  
      def connect
        token = cookies['token'] || request.params['token']
        reject_unauthorized_connection unless token
  
        # Tenta decodificar como user, senão como client
        begin
          payload = JwtService.decode(token) # => { "user_id" => ... }
          self.current_user = User.find(payload['user_id'])
        rescue
          begin
            payload = JwtClientService.decode(token) # => { "client_id" => ... }
            self.current_client = Client.find(payload['client_id'])
          rescue
            reject_unauthorized_connection
          end
        end
      end
    end
  end
  