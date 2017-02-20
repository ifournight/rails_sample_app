require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @micropost = Micropost.first
  end

  test 'Create post without log_in should fail' do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "Some random content", user: @user } }
    end
    assert_redirected_to login_url
  end

  test 'Destroy post without log_in should fail' do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end

  test 'should redirect when delete post with wrong user logged in' do
    log_in_as(@user)
    lana_first_post = users(:lana).microposts.first
    assert_no_difference 'Micropost.count' do
      delete micropost_path(lana_first_post)
    end
    assert_redirected_to root_url
  end
end
