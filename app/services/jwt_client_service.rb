class JwtClientService
    def self.secret
        ENV['JWT_CLIENT_SECRET'] || 'fallback_secret_dev'
    end

    def self.encode(payload)
        JWT.encode(payload, secret, 'HS256')
    end
    
    def self.decode(token)
        JWT.decode(token, secret, true, algorithm: 'HS256')[0]
    rescue JWT::DecodeError
        nil
    end
  end
  