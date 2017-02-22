class User < ApplicationRecord
    has_many :microposts, dependent: :destroy
    has_many :active_relationships,
                class_name: 'Relationship',
                foreign_key: 'follower_id',
                dependent: :destroy
    has_many :passive_relationships,
                class_name: 'Relationship',
                foreign_key: 'followed_id',
                dependent: :destroy
    has_many :following, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships
    accepts_nested_attributes_for :microposts
    attr_accessor :remember_token, :activation_token, :reset_token
    before_save :downcase_email
    before_create :create_activation_digest
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

    # General autheticate method: return true if the given token match the digest
    def autheticate?(key, token)
        digest_s = send("#{key.to_s.downcase}_digest")
        return false if digest_s.nil?
        BCrypt::Password.new(digest_s).is_password?(token)
    end

    # Activate an account
    def activate
        update_columns(activated: true, activated_at: Time.zone.now)
    end

    # Send Activation email
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    # Send password reset email
    def send_passwordreset_email
        UserMailer.password_reset(self).deliver_now
    end

    def create_reset_digest
        self.reset_token = User.new_token
        self.update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    end

    def password_reset_expire?
        self.reset_sent_at < 2.hours.ago
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

    # User's feed
    def feed
        following_ids = "SELECT followed_id FROM relationships
                            WHERE  follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids})
                            OR user_id = :user_id", user_id: id)
    end

    # Follow a user
    def follow(other_user)
        following << other_user
    end

    # Unfollow a user
    def unfollow(other_user)
        following.delete(other_user)
    end

    # Return true if current user is following the other user
    def following?(other_user)
        following.include?(other_user)
    end

    private

    def downcase_email
        self.email = email.downcase
    end

    def create_activation_digest
        self.activation_token = User.new_token
        self.activation_digest = User.digest(activation_token)
    end
end
