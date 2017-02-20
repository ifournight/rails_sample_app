require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper
  def setup
    @user = users(:michael)
  end

  test 'get user profile' do
    log_in_as(@user)
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title',
                  full_title(@user.name),
                  "title should match user's name"
    assert_select 'h1', { text: @user.name }, "h1 match user's name"
    assert_select 'h1>img.gravatar', true, "have user's gravatar"
    if !@user.microposts.empty?
      assert_match @user.microposts.count.to_s, response.body
      assert_select 'div.pagination'
    else
      assert_select '.microposts', false
    end
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
