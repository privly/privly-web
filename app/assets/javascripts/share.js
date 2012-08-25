/**
 * Regular Expression for validating IP addresses (number and dots only)
 */
var validIpAdressRegex = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/;
 
/**
  * Assigns message and form element of identities based on their value
  *
  * @param identity string The identity string to be processed
  * @param messageNode node The jquery node to assign the share type
  * @param hiddenElement The hidden form element for identifying the ID type
  */
function identityIdAndMessage(identity, messageNode, hiddenElement)
{
  if ( identity.indexOf("@") == 0 ) {
    messageNode.text("Domain Share");
    hiddenElement.val("Privly Verified Domain");
  }
  else if( identity.indexOf("@") > 0 ) {
    messageNode.text("Email Share");
    hiddenElement.val("Privly Verified Email");
  }
  else if( validIpAdressRegex.test(identity) ) {
    messageNode.text("IP Address");
    hiddenElement.val("IP Address");
  }
  else {
    messageNode.text("Password (Don't resuse this password)");
    hiddenElement.val("Password");
  }
}
