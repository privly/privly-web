require 'test_helper'

class ZeroBinTest < ActiveSupport::TestCase
  
  test "should not save Zero Bin without content" do
    zero_bin = ZeroBin.new
    zero_bin.iv = ""
    zero_bin.salt = ""
    zero_bin.ct = ""
    zero_bin.burn_after_date = Time.now + 1.hour
    assert !zero_bin.save
    
    zero_bin = ZeroBin.new
    zero_bin.iv = "initialization_vector"
    zero_bin.burn_after_date = Time.now + 1.hour
    assert !zero_bin.save
    
    zero_bin = ZeroBin.new
    zero_bin.salt = "Salt"
    zero_bin.burn_after_date = Time.now + 1.hour
    assert !zero_bin.save
    
    zero_bin = ZeroBin.new
    zero_bin.iv = "initialization_vector"
    zero_bin.salt = "Salt"
    zero_bin.burn_after_date = Time.now + 1.hour
    assert !zero_bin.save
    
    zero_bin = ZeroBin.new
    zero_bin.ct = "Content"
    zero_bin.burn_after_date = Time.now + 1.hour
    assert !zero_bin.save
    
    zero_bin = ZeroBin.new
    zero_bin.iv = "initialization_vector"
    zero_bin.ct = "Content"
    zero_bin.burn_after_date = Time.now + 1.hour
    assert !zero_bin.save
    
    zero_bin = ZeroBin.new
    zero_bin.salt = "Salt"
    zero_bin.ct = "Content"
    zero_bin.burn_after_date = Time.now + 1.hour
    assert !zero_bin.save
  end
  
  test "should save post" do
    zero_bin = ZeroBin.new
    zero_bin.iv = "initialization_vector"
    zero_bin.salt = "Salt"
    zero_bin.ct = "Content"
    zero_bin.burn_after_date = Time.now + 1.hour
    assert zero_bin.save
  end
  
  test "should not save post without burn_after_date" do
    zero_bin = ZeroBin.new
    zero_bin.iv = "initialization_vector"
    zero_bin.salt = "Salt"
    zero_bin.ct = "Content"
    assert !zero_bin.save
  end
end
