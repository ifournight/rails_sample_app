require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear

    @user = users(:michael)
  end
  test "Open Password reset page" do
    get new_password_reset_path
    assert_template 'password_resets/new'
  end

  test "Apply password reset with invalid email" do
    get new_password_reset_path
    post password_resets_url params:
                             {
                               password_reset:
                               {
                                 email: 'invalid@no_exsit.com'
                               }
                             }
    assert_template 'password_resets/new'
    assert_not flash.empty?
  end

  test "Apply password reset with valid email" do
    get new_password_reset_path
    post password_resets_url params:
                             {
                               password_reset:
                                 {
                                   email: @user.email
                                 }
                             }
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    # user has password_reset digest
    assert_not user.reset_digest.empty?
    follow_redirect!
    assert_template 'home'
    assert_select 'div.alert-success'
  end

  test "password reset request with invalid email/ token" do
    @user.create_reset_digest
    get edit_password_reset_path(@user.reset_token, email: "wrong@mail.com")
    follow_redirect!
    assert_template 'home'
    get edit_password_reset_path("invalid reset token", email: @user.email)
    follow_redirect!
    assert_template 'home'
  end

  test "password reset request with expired token" do
    @user.create_reset_digest
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    get edit_password_reset_path(@user.reset_token, email: @user.email)
    assert_not flash.empty?
    assert_redirected_to new_password_reset_url
    follow_redirect!
    assert_select 'div.alert-danger'
    assert_match 'Password reset has expired.', response.body
  end

  test 'password reset request with valid info' do
    @user.create_reset_digest
    get edit_password_reset_path(@user.reset_token, email: @user.email)
    assert_response :success
    assert_template "password_resets/edit"
  end

  test 'password reset submit with empty password' do
    @user.create_reset_digest
    patch password_reset_path(@user.reset_token,
                              email: @user.email,
                              user:
                              {
                                password: '',
                                password_confirmation: ''
                              })
    assert_template 'password_resets/edit'
    # how to test user password reset fail?
  end

  test 'password reset with wrong password combination' do
    @user.create_reset_digest
    patch password_reset_path(@user.reset_token,
                              email: @user.email,
                              user:
                              {
                                password: 'password1',
                                password_confirmation: 'password2'
                              })
    assert_template 'password_resets/edit'
    # how to test user password reset fail?
  end

  test 'password reset with valid password conbination' do
    @user.create_reset_digest
    patch password_reset_path(@user.reset_token,
                              email: @user.email,
                              user:
                              {
                                password: 'password',
                                password_confirmation: 'password'
                              })
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @user
  end
end
