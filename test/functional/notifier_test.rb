require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "Can send update email" do
    start_time = Time.now
    user = User.first
    Notifier.update_invited_user(user)
    assert user.last_emailed > start_time
  end
  
  test "Can send pending invitation email" do
    start_time = Time.now
    user = User.first
    Notifier.pending_invitation(user)
    assert user.last_emailed > start_time
  end
end
