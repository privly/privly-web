This API provides for serialized JSON storage for [privly-applications](https://github.com/privly/privly-applications)-- this means it is intended to be a key-value store where the key is the URL and the value is a JSON object. To create or edit content on the server, you will need to be acquainted with how the server handles CSRF, sessions, and content. Most Privly code must run in both a hosted context (ie, a web server sent the client the web application) and locally served context (the extension serves the code). This creates some unique concerns for a web service and inspires this API.

# Version History

**Version:** 0.1, Wrote this document

# CSRF Protection

"Cross Site Request Forgery" protection is built into Ruby on Rails by default, which means you need to have a random token established by the server before you can create or modify content. All non-get requests require you to set a CSRF header, ex:

`X-CSRF-Token:QjutSPGSGq+CMsw2+RpgyVAJcjZ3sQF53wcEl9wpWdg=`

Where "X-CSRF-Token" is the header name and "QjutSPGSGq+CMsw2+RpgyVAJcjZ3sQF53wcEl9wpWdg=" is the token established by the server.

You retrieve this token from the content server with a GET request to `/posts/user_account_data`, which returns the following JSON:

    {
      csrf: "QjutSPGSGq+CMsw2+RpgyVAJcjZ3sQF53wcEl9wpWdg=",//string
      burnAfter: "2014-01-26T10:35:47-07:00",              //string
      canPost: true,                                       //boolean
      signedIn: true                                       //boolean
    }

Users who can post will have both "canPost" and "signedIn" set to "true." "burnAfter" specifies when the content on the server will be destroyed.

The CSRF tokens are automatically saved and used for future requests when [privlyNetworkService.initPrivlyService()](https://github.com/privly/privly-applications/blob/master/shared/javascripts/network_service.js) is called in the Privly-applications.

# Sessions

All content on the server is tied to confirmed user accounts so users must establish a session with the server. Sessions are declared to the server either via a session cookie, or by an auth token. The auth token is generally used for devices, but the session cookie is used by extensions and hosted Privly applications.

Sessions tell the server who the user is, but the CSRF token is also required to protect the user from CSRF.

## Cookie Based Sessions

This server will set a session cookie when an acceptable username and password are sent to `/users/sign_in`.

POST request parameters:

"user[email]" : "email@domain.com"  
"user[password]" : "password"  

**Requires CSRF token (see above).**

To invalidate the session cookie, you should send a `delete` request to `/users/sign_out`.

## Token Based Sessions

Auth tokens can be added to requests as a parameter to identify the user and grant them access to their user account. This option is primarily used for devices with long-lived sessions.

POST request to '/token_authentications.:format'

**Parameters**

"email" : "email@domain.com"  
"password" : "password"

To experiment with token generation, you can view the forms at `/token_authentications/new`.

The auth token can be automatically added to AJAX requests if you first call  [privlyNetworkService.setAuthTokenString()](https://github.com/privly/privly-applications/blob/master/shared/javascripts/network_service.js) with the auth token before making requests.

**Does not require CSRF token.**

To destroy the current authentication token you should generate a new token and choose not to store it.

# Posts

The "posts" endpoint is the storage endpoint for content. 404'd requests are also answered with 403 status codes to obscure whether content exists on the server. All requests should request JSON content.

**Requires CSRF token (see above).**

## Creating New Content

Create a post.

POST /posts.json

**Parameters**  

post[content] - string - Optional

* Values: Any Markdown formatted string. No images supported.
* Default: nil

The content is rendered on the website, or for injection into web pages.

**post[structured_content]** - JSON - Optional
* Values: Any JSON document
* Default: nil
Structured content is for the storage of serialized JSON in the database.

**post[privly\_application]** - string - Optional

* Values: Any of the currently supported Privly application identifiers can
be set here. Current examples include "PlainPost" and "ZeroBin", but no
validation is performed on the string. It is only used to generate URLs
into the static folder of the server.
* Default: nil

**post[public]** - boolean - Optional

* Values: true, false
* Default: nil

A public post is viewable by any user.

**post[random\_token]** - string - Optional

* Values: Any string
* Default: A random sequence of Base64 characters

The random token is used to permission requests to content
not owned by the requesting user. It ensures the user has access to the link,
and not didn't crawl the resource identifiers.

**post[seconds\_until\_burn]** - integer - Optional

* Values: 1 to 99999999
* Default: nil

The number of seconds until the post is destroyed.

If this parameter is specified, then the burn\_after\_date
is ignored.

**post[burn\_after\_date(1i)]** - integer - Required

* Values: 2012
* Default: 2012

The year in which the content will be destroyed

**post[burn\_after\_date(2i)]** - integer - Required

* Values: 1 to 12
* Default: current month

The month in which the content will be destroyed

**post[burn\_after\_date(3i)]** - integer - Required

* Values: 1 to 31
Default: Defaults to two days from now if the user
is not logged in, otherwise it defaults to 14 days from now

The day after which the content will be destroyed. The combined day, 
month, and year must be within the next 14 days for users with
posting permission, or 2 days for users without posting permission.

**post[share[share\_csv]]** - csv - Optional

* Values: a single row of comma separated values
* Default: nil

Send in comma separated values representing identities
like domains, emails, and IP Addresses.

**post [share [can\_show]]** - boolean - Optional

* Values: true, false
* Default: true

Assign a show sharing permission to the share\_csv row's values

**post [share [can\_update]]** - boolean - Optional

* Values: true, false
* Default: false

Assign a update sharing permission to the share\_csv row's values

**post [share [can\_destroy]]** - boolean - Optional

* Values: true, false
* Default: false

Assign a destroy sharing permission to the share\_csv row's values

**post [share [can\_share]] **- boolean - Optional

* Values: true, false
* Default: false

Assign a share sharing permission to the share\_csv row's values


**Response Headers**  

* X-Privly-Url The URL for this content which should be posted to other
websites.

## Updating Content

Update a post. Requires update permission or content ownership. 

PUT /posts/:id  
PUT /posts/:id.:format

**id** - integer - Required

* Values: 0 to 9999999
* Default: None 

The identifier of the post.

**random\_token** - string - Required

* Values: Any string of non-whitespace characters
* Default: None 

Either the user owns the post, or they must supply this parameter.
Without this parameter, even with complete share access to the content,
the user will not be able to access this endpoint.

**post[content]** - string - Optional

* Values: Any Markdown formatted string. No images supported.
* Default: nil 

The content is rendered on the website, or for injection into web pages.

**post [structured\_content]** - JSON - Optional

* Values: Any JSON document
* Default: nil

Structured content is for the storage of serialized JSON in the database.

**post[public]** - boolean - Optional

* Values: true, false
* Default: nil

A public post is viewable by any user.

**post [random\_token]** - string - Optional

* Values: Any string
* Default: A random sequence of Base64 characters
The random token is used to permission requests to content
not owned by the requesting user. It ensures the user has access to the link,
and not didn't crawl the resource identifiers.

**post [seconds\_until\_burn]** - integer - Optional

* Values: 1 to 99999999
* Default: nil

The number of seconds until the post is destroyed.
If this parameter is specified, then the burn\_after\_date
is ignored. Requires destroy permission.


**post [burn\_after\_date(1i)]** - integer - optional

* Values: 2012
* Default: 2012

The year in which the content will be destroyed
Requires destroy permission.

**post [burn\_after\_date(2i)]** - integer - optional

* Values: 1 to 12
* Default: current month

The month in which the content will be destroyed
Requires destroy permission.

**post [burn\_after\_date(3i)]** - integer - optional

* Values: 1 to 31

Default: Defaults to thirty days from now.

**Response Headers**

* X-Privly-Url The URL for this content which should be posted to other
websites.

## Destroying Content

Destroy a post. Requires destroy permission, or content ownership.

DELETE /posts/:id  
DELETE /posts/:id.:format

**Parameters**  

**id** - integer - Required

* Values: 0 to 9999999
* Default: None 

The identifier of the post.

**random\_token** - string - Required

* Values: Any string of non-whitespace characters
* Default: None 

Either the user owns the post, or they must supply this parameter.
Without this parameter, even with complete share access to the content,
the user will not be able to access this endpoint.

## Viewing Content

Shows an individual post. The "owning user" is the user who created the original content behind the link. The owning user will be the only one with access to metadata for the post.

GET: /posts/:id.:format

Example:
    
    {"created_at":"2012-09-05T04:08:31Z", // when the content was created (owning user only)
     "burn_after_date":"2012-09-19T04:08:31Z", // when the content will be destroyed
     "public":false, // whether everyone has read permission
     "updated_at":"2012-09-05T04:08:31Z", // when the content was updated (owning user only)
     "structured_content":{ // the content serialized by and for the privly-application
       "salt":"ytyzBr2OkEc",
       "iv":"RSBeCnAklAbi0qvq/P8twA",
       "ct":"23hqJJ7QKNkxpLVtfp9uEg"},
     "id":149, //the unique id of the content
     "user_id":2, //the id of the creating user. (owning user only)
     "content":null, // public cleartext content. this may be deprecated
     "random_token":"a53642b006", //see below
     "permissions":{ //current user's permissions on contents
       canshow: true,
       canupdate: false,
       candestroy: false, 
       canshare: false}
    }

**Parameters**

**random_token** - string - Required

* Values: Any string of non-whitespace characters
* Default: None 

Either the user owns the post, or they must supply this parameter.
Without this parameter, even with complete share access to the content,
the user will not be able to access this content.

**Response Headers**

* X-Privly-Url The URL for this content which should be posted to other
websites.

## Index of Content

Get a list of all the user's posts. The user must be authenticated. 

GET: /posts.json

The result is an array of data objects similar to the one described in the "show" endpoint. Example result:

    [
      {"created_at":"2012-09-05T04:08:31Z",
       "burn_after_date":"2012-09-19T04:08:31Z",
       "public":false,
       "updated_at":"2012-09-05T04:08:31Z",
       "structured_content": {
         "salt":"ytyzBr2OkEc",
         "iv":"RSBeCnAklAbi0qvq/P8twA",
         "ct":"23hqJJ7QKNkxpLVtfp9uEg"},
       "id":149,
       "user_id":2,
       "content":null,
       "random_token":"a53642b006"
       },
       ...
    ]

# Shares

We built rule-based authorization into the server for sharing by email, domain, IP address, and password, but this functionality is hidden by default. If you are self-hosting a server this functionality can be useful, but in general it is better to base confidentiality on cryptographic operations that remove trust from the hosting provider. Server-side authorization does not pass this test.
