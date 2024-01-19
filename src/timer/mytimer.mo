import { print } = "mo:base/Debug";
import { recurringTimer } = "mo:base/Timer";
import HttpTypes "HttpTypes";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Iter "mo:base/Iter";



actor {
  let oneSecond = 1_000_000_000; // nanoseconds
  let tenSecond = 1_000_000_000_0; // nanoseconds
  let tenSecond10 = 1_000_000_000_00; // nanoseconds

  private func printHello() : async () {


    print("Hello, World!");
  };


  ignore recurringTimer(#nanoseconds tenSecond10, printHello);
  stable var entries : [(Text, Text)] = [];
  var myUserInfoMap = HashMap.fromIter<Text,Text>(entries.vals(), 32, Text.equal, Text.hash);

  // stable let myUserInfoMap : HashMap.HashMap<Text, Text> = HashMap.HashMap(32, Text.equal, Hash.hash);





public func send_http_post_request(input:Text) : async [(Text, Text)] {

    print("=======================================================");
    print(input);
    print("=======================================================");
    entries:=[]; 
    let ic : HttpTypes.IC = actor ("aaaaa-aa");
    let host : Text = "l2827e4fsc.execute-api.ap-southeast-1.amazonaws.com";
    let url = "https://l2827e4fsc.execute-api.ap-southeast-1.amazonaws.com/api/vft-query-nodejs"; //HTTP that accepts IPV6
    // let testData: Text = "123,gjhgfgj,sbt,100\n124,gjhgfgj,sbt,200\n";
    let lines = Iter.toArray(Text.split(input, #char '\n'));
    for (outerElement in Array.vals(lines)) {
      if (outerElement.size() > 0) {
        addEntry(Iter.toArray(Text.split(outerElement, #char ','))[0],outerElement);
      }
    };

    // 2.2 prepare headers for the system http_request call

    //idempotency keys should be unique so we create a function that generates them.
    let idempotency_key: Text = generateUUID();
    let request_headers = [
        { name = "Host"; value = host # ":443" },
        { name = "User-Agent"; value = "http_post_sample" },
        { name= "Content-Type"; value = "application/json" },
        { name= "Idempotency-Key"; value = idempotency_key }
    ];
    let request_body_json: Text = "{ \"demo\" : \"demo\"}";
    let request_body_as_Blob: Blob = Text.encodeUtf8(request_body_json); 
    let request_body_as_nat8: [Nat8] = Blob.toArray(request_body_as_Blob); // e.g [34, 34,12, 0]

    let transform_context : HttpTypes.TransformContext = {
      function = transform;
      context = Blob.fromArray([]);
    };


    let http_request : HttpTypes.HttpRequestArgs = {
        url = url;
        max_response_bytes = null; //optional for request
        headers = request_headers;
        //note: type of `body` is ?[Nat8] so we pass it here as "?request_body_as_nat8" instead of "request_body_as_nat8"
        body = ?request_body_as_nat8; 
        method = #post;
        transform = ?transform_context;
    };

    Cycles.add(230_850_258_000);
    let http_response : HttpTypes.HttpResponsePayload = await ic.http_request(http_request);

    let response_body: Blob = Blob.fromArray(http_response.body);
    let decoded_text: Text = switch (Text.decodeUtf8(response_body)) {
        case (null) { "No value returned" };
        case (?y) { y };
    };



    //6. RETURN RESPONSE OF THE BODY
    let result: Text = decoded_text # ". See more info of the request sent at: " # url # "/inspect";
    let currentTime = Time.now();
    entries
  };

  func addEntry(key: Text, value: Text) : () {
    let myUserInfoMap = HashMap.HashMap<Text,Text>(32, Text.equal, Text.hash);
    for ((k, v) in entries.vals()) {
        myUserInfoMap.put(k, v);
    };
    myUserInfoMap.put(key, value);
    entries:=Iter.toArray<(Text, Text)>(myUserInfoMap.entries());
  };

  public query func transform(raw : HttpTypes.TransformArgs) : async HttpTypes.CanisterHttpResponsePayload {
      let transformed : HttpTypes.CanisterHttpResponsePayload = {
          status = raw.response.status;
          body = raw.response.body;
          headers = [
              {
                  name = "Content-Security-Policy";
                  value = "default-src 'self'";
              },
              { name = "Referrer-Policy"; value = "strict-origin" },
              { name = "Permissions-Policy"; value = "geolocation=(self)" },
              {
                  name = "Strict-Transport-Security";
                  value = "max-age=63072000";
              },
              { name = "X-Frame-Options"; value = "DENY" },
              { name = "X-Content-Type-Options"; value = "nosniff" },
          ];
      };
      transformed;
  };

  func generateUUID() : Text {
    "UUID-123456789";
  };
}