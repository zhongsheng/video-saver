require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "wechat_openid must be unique" do
    User.create!(wechat_openid: "unique-openid")

    duplicate = User.new(wechat_openid: "unique-openid")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:wechat_openid], "has already been taken"
  end
end
