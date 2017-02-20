require 'test_helper'

class CreatePostTest < ActionDispatch::IntegrationTest
  def setup
    @user         = users(:michael)
    @another_user = users(:lana)
  end

  test 'Create post test' do
    log_in_as(@user)
    get root_url
    assert_select 'div.pagination'
    assert_select 'input[type="file"]'
    @micropost = @user.microposts.build
    assert_no_difference 'Micropost.count' do
      post microposts_path(@micropost), params:
                                              {
                                                micropost:
                                                {
                                                  content: ''
                                                }
                                              }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_select 'div#error_explanation'
    content = 'valid content'
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path(@micropost), params:
                                              {
                                                micropost:
                                                {
                                                  content: content,
                                                  picture: picture
                                                }
                                              }

    end

    @micropost = assigns(:micropost)
    assert @micropost.picture?
    assert_select 'div#error_explanation', false
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    
    log_out_current_user
    @micropost = @user.microposts.first
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    
    assert_redirected_to login_url
    log_in_as(@another_user)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end

    log_out_current_user
    log_in_as(@user)
    get root_url
    content = @micropost.content
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(@micropost)
    end
    assert_not flash.empty?
    assert_redirected_to root_url
    follow_redirect!
    assert_no_match content, response.body
    assert_select 'div.alert-success'
  end
end
