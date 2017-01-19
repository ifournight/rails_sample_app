class User < ApplicationRecord
    attr_accessor :remember_token
    before_save { self.email = email.downcase }
    validates :name, presence: true,
                    length: {maximum: 50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true,
                    length: {maximum: 150},
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

    # Generate and save a token for session login
    def remember
        self.remember_token = User.new_token
        self.update_attribute(:remember_digest, User.digest(self.remember_token))
    end

    # Forget user's token for session login
    def forget
        self.remember_token = nil
        self.update_attribute(:remember_digest, nil)
    end

    # Verity if given token match user's remember_digest
    def autheticate?(remember_token)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end

    # Returns the hash digest of the given string.
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # Generate a new token
    def User.new_token
        SecureRandom.urlsafe_base64
    end
end
