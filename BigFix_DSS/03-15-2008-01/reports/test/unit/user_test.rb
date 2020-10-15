require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

  def test_should_create_user
    assert_difference User, :count do
      user = create_user()
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference User, :count do
      u = create_user(:username => nil)
      assert u.errors.on(:username)
    end
  end

  def test_should_require_password
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference User, :count do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:john_doe).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:john_doe), User.authenticate('john_doe', 'new password')
  end

  def test_should_not_rehash_password
    users(:john_doe).update_attributes(:username => 'john_doe2')
    assert_equal users(:john_doe), User.authenticate('john_doe2', 'foobar')
  end

  def test_should_authenticate_user
    assert_equal users(:john_doe), User.authenticate('john_doe', 'foobar')
  end

  def test_should_set_remember_token
    users(:john_doe).remember_me
    assert_not_nil users(:john_doe).remember_token
    assert_not_nil users(:john_doe).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:john_doe).remember_me
    assert_not_nil users(:john_doe).remember_token
    users(:john_doe).forget_me
    assert_nil users(:john_doe).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:john_doe).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:john_doe).remember_token
    assert_not_nil users(:john_doe).remember_token_expires_at
    assert users(:john_doe).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:john_doe).remember_me_until time
    assert_not_nil users(:john_doe).remember_token
    assert_not_nil users(:john_doe).remember_token_expires_at
    assert_equal users(:john_doe).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:john_doe).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:john_doe).remember_token
    assert_not_nil users(:john_doe).remember_token_expires_at
    assert users(:john_doe).remember_token_expires_at.between?(before, after)
  end

  protected
    def create_user(options = {})
      User.create({ :name => 'Quire', :username => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end
