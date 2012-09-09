/**
 * Regular Expression for validating IP addresses (number and dots only)
 */
var validIpAdressRegex = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/;
 
/**
  * Assigns message and form element of identities based on their value
  *
  * @param identity string The identity string to be processed
  * @param messageNode node The jquery node to assign the share type
  * @param hiddenElement node The hidden form element for identifying the ID type
  */
function identityIdAndMessage(identity, messageNode, hiddenElement)
{
  
  if ( identity.indexOf(" ") > 0 || identity.indexOf(",") > 0) {
    //write new block to toggle which form element is displayed, carry over values, register/unregister event listeners
    messageNode.text("List of Shares (comma or space separated)");
    hiddenElement.val("");
  } 
  else if ( identity === "" ) {
    messageNode.text("Type an Email, domain, IP Address, or password ");
    hiddenElement.val("");
  }
  else if ( identity.indexOf("@") === 0 ) {
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
    messageNode.text("Password (this functionality is active in the next version)");
    hiddenElement.val("Password");
  }
}

/**
 *
 * Swaps share identity into secondary form element if its type is unkown.
 * This is used for server side share type determination, or the processing
 * of multiple shares in the form of a CSV.
 *
 * @param identity node The identity node containing the identity string.
 * This node will be set to the empty string if the swapIfEmpty node is
 * empty.
 * @param identityDestination node The node to receive the identity string
 * if the swapIfEmpty node is empty.
 * @param swapIfEmpty node A node whose emptiness indicates that the values
 * should be swapped.
 *
 */
function sharesFormSubmit(identity, identityDestination, swapIfEmpty) {
  if (swapIfEmpty.val() === "") {
    identityDestination.val(identity.val());
    identity.val("");
  }
}

