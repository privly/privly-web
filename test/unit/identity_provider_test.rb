require 'test_helper'

class IdentityProvidersTest < ActiveSupport::TestCase
  
  setup do
    
    @email_identity = IdentityProvider.find_by_name("Privly Verified Email")
    @domain_identity = IdentityProvider.find_by_name("Privly Verified Domain")
    @password_identity = IdentityProvider.find_by_name("Password")
    @ip_address_identity = IdentityProvider.find_by_name("IP Address")
    
  end
  
  test "should downcase share identities" do
    assert @email_identity.format_identity("UPPERCASE@EMAIL.COM") == "uppercase@email.com"
    assert @domain_identity.format_identity("@EMAIL.COM") == "@email.com"
  end
  
  test "should give email share error message" do
    assert @email_identity.validate_identity("@EMAIL.COM")
    assert @email_identity.validate_identity("email@")
    assert @email_identity.validate_identity("a@.COM")
    assert @email_identity.validate_identity("@email.com")
    assert @email_identity.validate_identity("yourmailatEMAIL.COM")
  end
  
  test "should give domain share error message" do
    assert @domain_identity.validate_identity("a@EMAIL.COM")
    assert @domain_identity.validate_identity("email@")
    assert @domain_identity.validate_identity("a@.COM")
    assert @domain_identity.validate_identity("@.com")
    assert @domain_identity.validate_identity("@yourmailatEMAIL")
  end
  
  test "should give password share error message" do
    assert @password_identity.validate_identity("skdaksjhfsafkjh")
    assert @password_identity.validate_identity("@domain.com")
    assert @password_identity.validate_identity("email@domain.com")
    assert @password_identity.validate_identity("127.0.0.1")
  end
  
  test "should give IP Address share error message" do
    assert @ip_address_identity.validate_identity("1234.1.1.0")
    assert @ip_address_identity.validate_identity("124.1.1.0000")
    assert @ip_address_identity.validate_identity("123.1.1.0:3000")
    assert @ip_address_identity.validate_identity("1234.1.1.0")
    assert @ip_address_identity.validate_identity("@domain.com")
    assert @ip_address_identity.validate_identity("email@domain.com")
    assert @ip_address_identity.validate_identity("1270.0.1")
  end
  
  test "should not give email share error message" do
    assert @email_identity.validate_identity("email@EMAIL.COM") == ""
    assert @email_identity.validate_identity("email@priv.ly") == ""
    assert @email_identity.validate_identity("a@aa.COM") == ""
    assert @email_identity.validate_identity("abcdefg@email.tv") == ""
    assert @email_identity.validate_identity("yourmail@EMAIL.COM") == ""
  end
  
  test "should not give domain share error message" do
    assert @domain_identity.validate_identity("@EMAIL.COM") == ""
    assert @domain_identity.validate_identity("@aa.com") == ""
    assert @domain_identity.validate_identity("@nyt.tv") == ""
    assert @domain_identity.validate_identity("@h20watch.net") == ""
    assert @domain_identity.validate_identity("@bazinga.wow.wow.subdomains.many") == ""
  end
  
  test "should not give IP Address share error message" do
    assert @ip_address_identity.validate_identity("124.1.1.0") == ""
    assert @ip_address_identity.validate_identity("168.1.1.000") == ""
    assert @ip_address_identity.validate_identity("999.1.1.0") == ""
    assert @ip_address_identity.validate_identity("123.27.1.0") == ""
  end
  
end
