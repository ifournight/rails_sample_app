require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:malory)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_select '#following' do |elements|
      elements.each do |element|
        assert_match @user.following.count.to_s, element.content
      end
    end
    @user.following.each do |followed|
      assert_select 'a[href=?]', user_path(followed)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_select '#followers' do |elements|
      elements.each do |element|
        assert_match @user.followers.count.to_s, element.content
      end
    end
    @user.followers.each do |follower|
      assert_select 'a[href=?]', user_path(follower)
    end
  end

  test "follow user a standard way" do
    assert_difference 'Relationship.count', 1 do
      post relationships_path, params: { followed_id: @other_user.id }
    end
  end

  test "follow user a ajax way" do
    assert_difference 'Relationship.count', 1 do
      post relationships_path, xhr: true, params: { followed_id: @other_user.id }
    end
  end

  test "unfollow a standard way" do
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
    assert_difference 'Relationship.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "unfollow a xhr way" do
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
    assert_difference 'Relationship.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end

  test "feed on home page" do
    get root_url
    @user.feed.paginate(page: 1).each do |micropost|
      selector = "#micropost-#{micropost.id}"
      assert_select selector
    end
  end
end
