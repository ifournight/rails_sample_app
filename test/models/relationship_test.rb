require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id)
  end

  test "Relationship validation" do
    assert @relationship.valid?

    @relationship.followed_id = nil
    assert_not @relationship.valid?

    @relationship.followed_id = users(:michael).id
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end
end
