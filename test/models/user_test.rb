require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new name: "Example User", email: "user@example.com", password: "codebone", password_confirmation: "codebone"
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "      "
    assert_not @user.valid?
  end

  test "name's length should be under 50" do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test "email's length should be under 150" do
    @user.email = 'a' * (151 - 'example.com'.length) + 'example.com'
    assert_not @user.valid?
  end

  test "email should be unique" do
    @user.email = "ifournight@gmail.com"
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email should check format validation" do
    invalid_emails = %w[ifournight@gmail,com if#gmail.com he^qq.com]
    invalid_emails.each do |i_e|
      @user.email = i_e
      assert_not @user.valid?
    end
  end

  test "email should be saved as lower-case" do
    mixd_case_email = "Foo@ExAMPle.coM"
    @user.email = mixd_case_email;
    @user.save
    assert_equal mixd_case_email.downcase, @user.email
  end

  test "password should not be blank" do
    @user.password = @user.password_confirmation = ' ' * 6;
    @user.save
    assert_not @user.valid?
  end

  test "password should be 6 length at least" do
    @user.password = @user.password_confirmation = "f" * 5;
    @user.save
    assert_not @user.valid?
  end

  test "autheticate? should return false for a user with nil remember_digest" do
    assert_not @user.autheticate?(:remember, "")
  end

  test 'associated microposts should be destroyed' do
    @user.save
    @user.microposts.create!(content: 'lalalalala')
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
end
