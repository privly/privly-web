// This file was recently moved from the post's show action and needs
// refactoring to become library functions. These functions handle
// the generation of Privly-Type URLs with extra options.

/**
 * Converts an associative array to an encoded string
 * for appending to the anchor.
 *
 * @param object associative_array Object to be serialized
 * @return string
 */
function hashToParameterString(associativeArray)
{
  var parameterString = ""
  for (key in associativeArray)
  {
      if( parameterString === "" )
      {
        parameterString = encodeURIComponent(key);
        parameterString += "=" + encodeURIComponent(associativeArray[key]);
      } else {
        parameterString += "&" + encodeURIComponent(key);
        parameterString += "=" + encodeURIComponent(associativeArray[key]);
      }
  }
  
  //padding for URL shorteners
  if (parameterString !== "") {
    parameterString += "&p=p";
  }
  
  return parameterString;
}

/**
 * Converts a string to an associative array.
 *
 * @param string parameter_string String containing parameters
 * @return object
 */
function parameterStringToHash(parameterString)
{
  var parameterHash = {};
  var parameterArray = parameterString.split("&");
  for (var i = 0; i < parameterArray.length; i++) {
    //var currentParamterString = decodeURIComponent(parameterArray[i]);
    var pair = parameterArray[i].split("=");
    var key = decodeURIComponent(pair[0]);
    var value = decodeURIComponent(pair[1]);
    parameterHash[key] = value;
  }

  return parameterHash;
}

/**
 * Get an associative arroy of the parameters found in the anchor
 *
 * @return object
 **/
function getParameterHash()
{
  var hashIndex = window.location.href.indexOf("#");
  if (hashIndex >= 0) {
    return parameterStringToHash(window.location.href.substring(hashIndex + 1));
  } else {
    return {};
  }
}

/**
 * Fills the link options form with the current parameter values and
 * deactivates the pre-filled parameters.
 */
function fillFormStartingValues()
{
  var currentParameters = getParameterHash();
  var elem = document.getElementById('linkFormatterForm').elements;
  for(var i = 0; i < elem.length; i++)
  {
      if(elem[i].getAttribute("use_in_url") == "true")
      {
        if (currentParameters[elem[i].name] !== undefined) {
          elem[i].value = currentParameters[elem[i].name];
          elem[i].disabled = true;
        }
      }
  }
}

/**
 * Collects the parameters from the "Link Options" sidebar and
 * assigns the newFormattedLink element to the generated URL
 */
function updateURL()
{
    var parameterObject = {};
    var elem = document.getElementById('linkFormatterForm').elements;
    for(var i = 0; i < elem.length; i++)
    {
        if(elem[i].getAttribute("use_in_url") == "true")
        {
            var val = elem[i].value;
            if(! val)
                continue;
            if(elem[i].type == "checkbox" && elem[i].checked != true)
                continue;
            parameterObject[elem[i].name] = val;
        }
    }
    
    var anchorIndex = window.location.href.indexOf("#");
    if (anchorIndex < 0) {
      anchorIndex = window.location.href.length + 1;
    }
    
    var newUrl = 
      window.location.href.substring(0, anchorIndex) + 
      "#" +
      hashToParameterString(parameterObject);
    document.getElementById('newFormattedLink').innerHTML = newUrl;
}

