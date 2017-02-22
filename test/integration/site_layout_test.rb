require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
  test "home page layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    get contact_path
    assert_select "title", full_title("Contact")

    log_in_as(@user)
    get root_url
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
    assert_select 'img.gravatar', true, 'Logged in home page should have user avatar'
    assert_select 'form', true, 'logged in home page should have form for create new post'
    if @user.feed.any?
      assert_select 'ol.microposts', true, 'Logged in home page should have user feed'
      assert_select 'div.pagination', true  
    end
    @user.feed.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
    assert_select 'a[href=?]', following_user_path(@user), true, 'Logged in home page display following link'
    assert_select 'a[href=?]', followers_user_path(@user), true, 'Logged in home page display followers link'
    assert_select '#following' do |elements|
      elements.each do |element|
        assert_match @user.following.count.to_s, element.content
      end
    end
    assert_select '#followers' do |elements|
      elements.each do |element|
        assert_match @user.followers.count.to_s, element.content
      end
    end
  end
end
