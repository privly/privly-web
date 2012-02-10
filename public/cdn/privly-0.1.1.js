/*******************************************************************************
Open Source Initiative OSI - The MIT License (MIT):Licensing
[OSI Approved License]
The MIT License (MIT)

Copyright (c) Sean McGregor

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to deal 
in the Software without restriction, including without limitation the rights 
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.

*******************************************************************************/

/*******************************************************************************
Privly host page script version 0.1.1
This javascript performs the following actions on the host page
1. Converts plain text links to anchor elements if they 
   point to either priv.ly/posts or localhost:3000/posts
2. Corrects possible link indirection (when the href does not 
   point to the same address that is shown in the link body)
3. Replaces Privly links with iframes pointing to the linked content
4. Resizes the injected iframe to match the height of the contents

*******************************************************************************/

var privly = {

  //Matches:
  //              http://
  //              https://
  //                        priv.ly/textAndNumbers/any/number/of/times
  //                                                                          
  //also matches localhost:3000
  privlyReferencesRegex: /\b(https?:\/\/){0,1}(priv\.ly|localhost:3000)(\/posts)(\/\w*){1,}\b/gi,
  
  // Takes a domain with an optional http(s) in front and returns a fully formed domain name
  makeHref: function(domain)
  {
    var hasHTTPRegex = /^((https?)\:\/\/)/i
    if(!hasHTTPRegex.test(domain)) 
        domain = "http://" + domain;
    return domain;
  },

  //Make plain text links into anchor elements
  createLinks: function() 
  {
      /*************************************************************************
      Inspired by Linkify script:
        http://downloads.mozdev.org/greasemonkey/linkify.user.js

      Originally written by Anthony Lieuallen of http://arantius.com/
      Licensed for unlimited modification and redistribution as long as
      this notice is kept intact.
      **************************************************************************/

      var excludeParents = ["a", "applet", "button", "code", "form",
                             "input", "option", "script", "select", "meta", 
                             "style", "textarea", "title", "div","span"];
      var excludedParentsString = excludeParents.join(" or parent::");
      var xpathExpression = ".//text()[not(parent:: " + excludedParentsString +")]";

      textNodes = document.evaluate(xpathExpression, document.body, null, 
                                    XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);

      for(var i=0; i < textNodes.snapshotLength; i++){
          item = textNodes.snapshotItem(i);

          var itemText = item.nodeValue;
          
          privly.privlyReferencesRegex.lastIndex = 0;
          if(privly.privlyReferencesRegex.test(itemText)){
              var span = document.createElement("span");    
              var lastLastIndex = 0;
              privly.privlyReferencesRegex.lastIndex = 0;
              for(var results = null; results = privly.privlyReferencesRegex.exec(itemText); ){
                  var href = results[0];
                  span.appendChild(document.createTextNode(itemText.substring(lastLastIndex, results.index)));

                  var text = (href.indexOf(" ")==0)?href.substring(1):href;

                  var href = privly.makeHref(text);

                  var a = document.createElement("a");
                  a.setAttribute("href", href);
                  a.appendChild(document.createTextNode(text.substring(0,4).toLowerCase()+text.substring(4)));
                  if(href.indexOf(" ")==0) 
                      span.appendChild(document.createTextNode(" "));
                  span.appendChild(a);
                  lastLastIndex = privly.privlyReferencesRegex.lastIndex;
              }
              span.appendChild(document.createTextNode(itemText.substring(lastLastIndex)));
              item.parentNode.replaceChild(span, item);
          }
      }
  },

  //Kill default link behaviour on Privly Links
  makePassive: function(anchor) 
  {    
    //Preventing the default link behavior
    anchor.addEventListener("mousedown", function(e){
        e.cancelBubble = true;
        e.stopPropagation();
        e.preventDefault();
        privly.replaceLink(anchor);
      }, 
      true);
  },
  
  //Checks link attributes and text for privly links without the proper href attribute.
  //Twitter and other hosts change links so they can collect click events.
  correctIndirection: function() 
  {
    var anchors = document.links;
    var i = anchors.length;
    while (i--){
      var a = anchors[i];
      
      if(a.href && (a.href.indexOf("priv.ly/posts/") == -1 || a.href.indexOf("priv.ly/posts/") > 9))
      {
        if (privly.privlyReferencesRegex.test(a.innerHTML)) {        
          // If the href is not present or is on a different domain
          privly.privlyReferencesRegex.lastIndex = 0;
          var results = privly.privlyReferencesRegex.exec(a.innerHTML);
          var newHref = privly.makeHref(results[0]);
          a.setAttribute("href", newHref);
        }
      }
    }
  },

  nextAvailableFrameID: 0,

  // Replace an anchor element with its referenced content.
  replaceLink: function(object) 
  { 
    var iFrame = document.createElement('iframe');
    iFrame.setAttribute("frameborder","0");
    iFrame.setAttribute("vspace","0");
    iFrame.setAttribute("hspace","0");
    iFrame.setAttribute("name","privlyiframe");
    iFrame.setAttribute("width","100%");
    iFrame.setAttribute("marginwidth","0");
    iFrame.setAttribute("marginheight","0");
    iFrame.setAttribute("height","1px");
    iFrame.setAttribute("src",object.href + ".iframe?frame_id=" + privly.nextAvailableFrameID);
    iFrame.setAttribute("id","ifrm"+privly.nextAvailableFrameID);
    iFrame.setAttribute("frameborder","0");
    privly.nextAvailableFrameID++;
    iFrame.setAttribute("style","width: 100%; height: 32px; overflow: hidden;");
    iFrame.setAttribute("scrolling","no");
    iFrame.setAttribute("overflow","hidden");
    
    object.parentNode.replaceChild(iFrame, object);
  },

  //Replace all Privly links with their iframe
  replaceLinks: function(){
    var anchors = document.links;
    var i = anchors.length;
    while (i--){
      var a = anchors[i];
      privly.privlyReferencesRegex.lastIndex = 0;
      if(a.href && privly.privlyReferencesRegex.test(a.href))
      {
        var exclude = a.getAttribute("privly");
        if(exclude != "exclude")
        {
          if(privly.active)
          {
            privly.replaceLink(a);
          }
          else
          {
            privly.makePassive(a);
          }
        }
      }
    }
  },

  //do nothing. Actual implementation is in extension-host-interface.js
  resizeIframe: function(evt){},
  
  //prevents DOMNodeInserted from sending hundreds of extension runs
  runPending: false,
  
  //prep the page and replace the links if it is in active mode
  run: function(){

    //create and correct the links pointing
    //to Privly content
    privly.createLinks();
    privly.correctIndirection();
    
    //replace all available links on load, if in active mode,
    //otherwise replace all links default behavior
    privly.replaceLinks();
  },
  
  //runs privly once then registers the update listener
  //for dynamic pages
  listeners: function(){
    
    //don't recursively replace links
    if(document.URL.indexOf('priv.ly') != -1 || document.URL.indexOf('localhost:3000') != -1)
      return;
    
    privly.runPending=true;
      setTimeout(
        function(){
          privly.runPending=false;
          privly.run();
        },
        100);
    
    //Everytime the page is updated via javascript, we have to check
    //for new Privly content. This might not be supported on other platforms
    document.addEventListener("DOMNodeInserted", function(event) {
      
      //we check the page a maximum of two times a second
      if(privly.runPending )
        return;
      privly.runPending=true;
      
      setTimeout(
        function(){
          privly.runPending=false;
          privly.run();
        },
        500);
    });
    
    //The content's iframe will fire a resize event when it has loaded, resizeIframe
    //sets the height of the iframe to the height of the content contained within.
    window.addEventListener("IframeResizeEvent", function(e) { privly.resizeIframe(e); }, false, true);
  },
  
  //indicates whether the extension shoud immediatly replace all Privly
  //links it encounters
  active: true,
  
  // cross platform onload event
  // won't attach anything on IE 
  // on macintosh systems.
  addEvent: function(obj, evType, fn){ 
   if (obj.addEventListener){ 
     obj.addEventListener(evType, fn, false); 
     return true; 
   } else if (obj.attachEvent){ 
     var r = obj.attachEvent("on"+evType, fn); 
     return r; 
   } else { 
     return false; 
   } 
  }
};

privly.addEvent(window, 'load', privly.listeners);
