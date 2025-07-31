# HTTP requests via CURL

```haxe
// Import the LfCurlRequest class
import leafy.network.LfCurlRequest;

/*
    Make the request and get the result as a string variable
    This example may not work, it's just an example
*/
var requestResult:String = LfCurlRequest.httpRequest("https://google.com", LfCurlRequestMethod.GET, "", []);
```

--------

See [``LfCurlRequest``](https://github.com/Slushi-Github/leafyEngine/blob/main/leafy/network/LfCurlRequest.hx)