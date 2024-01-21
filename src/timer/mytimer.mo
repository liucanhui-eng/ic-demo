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
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Time "mo:base/Time";
import Int "mo:base/Int";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Types "../nft/Types";
import Debug "mo:base/Debug";
import Bool "mo:base/Bool";

actor {
  let oneSecond = 1_000_000_000; // nanoseconds
  let tenSecond = 1_000_000_000_0; // nanoseconds
  let tenSecond10 = 1_000_000_000_000; // nanoseconds

  private func printHello() : async () {

    print("Hello, World!");
  };

  ignore recurringTimer(#nanoseconds tenSecond10, printHello);
  // save data
  stable var userInfoEntry : [(Nat, Types.VftUserInfo)] = [];
  // stable var vftRecordList : [Types.VftRecord] = [];
  stable var lastIndex : Nat = 0;
  stable var vftRecordList = List.nil<Types.VftRecord>();

  //var myUserInfoMap = HashMap.fromIter<Text,Text>(entries.vals(), 32, Text.equal, Text.hash);

  // stable let myUserInfoMap : HashMap.HashMap<Text, Text> = HashMap.HashMap(32, Text.equal, Hash.hash);

  // send a request get vft info
  public func work() : async Text {

    print("开始更新数据【更新前数据】=====================================================");
    // print("开始更新数据【更新前数据】");

    // Debug.print(debug_show (userInfoEntry));
    // Debug.print(debug_show (vftRecordList));

    var working : Bool = true;
    while (working) {
      let result = await do_send_post();
      working := doWork(result);
    };
    "处理成功";
  };

  func doWork(httpResp : Text) : Bool {
    if (httpResp == "-1") {
      return true;
    };
    let lines = Iter.toArray(Text.split(httpResp, #char ';'));
    var skip = false;
    for (outerElement in Array.vals(lines)) {
      if (outerElement.size() > 0 and skip) {
        buildRecord(outerElement);
      };
      skip := true;
    };
    // print("开始更新数据【更新后数据】");
    // Debug.print(debug_show (userInfoEntry));
    Debug.print(debug_show ("处理完成。开始下一次循环"));
    return false;
  };

  func do_send_post() : async Text {
    let idempotency_key : Text = generateUUID();
    let ic : HttpTypes.IC = actor ("aaaaa-aa");
    let host : Text = "l2827e4fsc.execute-api.ap-southeast-1.amazonaws.com";
    let url = "https://l2827e4fsc.execute-api.ap-southeast-1.amazonaws.com/api/vft-query-nodejs"; //HTTP that accepts IPV6
    let request_headers = [
      { name = "Host"; value = host # ":443" },
      { name = "User-Agent"; value = "http_post_sample" },
      { name = "Content-Type"; value = "application/json" },
      { name = "Idempotency-Key"; value = idempotency_key },
      { name = "task"; value = "vft" },
      { name = "index"; value = Nat.toText(lastIndex) },
    ];
    let request_body_json : Text = "{ \"demo\" : \"demo\"}";
    let request_body_as_Blob : Blob = Text.encodeUtf8(request_body_json);
    let request_body_as_nat8 : [Nat8] = Blob.toArray(request_body_as_Blob); // e.g [34, 34,12, 0]

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

    let response_body : Blob = Blob.fromArray(http_response.body);
    let decoded_text : Text = switch (Text.decodeUtf8(response_body)) {
      case (null) { "No value returned" };
      case (?y) { y };
    };

    //6. RETURN RESPONSE OF THE BODY
    // let result : Text = decoded_text # ". See more info of the request sent at: " # url # "/inspect";
    let result : Text = decoded_text;
    print(result);
    result;
  };

  public query func queryLastIndex() : async Nat {
    lastIndex;
  };
  public shared func cleanAll(index : Nat,pwd:Nat) : async Text {

    if(pwd!=123456){
      return "清除失败。身份验证出错";
    };

    lastIndex := index;
    userInfoEntry := [];
    vftRecordList := List.nil<Types.VftRecord>();
    "清除成功";
  };

  public query func queryUserInfoEntry() : async [(Nat, Types.VftUserInfo)] {
    userInfoEntry;
  };
  public query func queryRecordCount() : async Nat {
    List.size(vftRecordList);
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

  func buildRecord(line : Text) : () {
    //index,user_id,task_code,vft_total,timestamps
    let array = Iter.toArray(Text.split(line, #char ','));
    let index = array[0];
    let userId = array[1];
    let taskCode = array[2];
    let vftTotal = array[3];
    let timestamps = array[4];
    let record : Types.VftRecord = {
      index = TextToNat(index);
      task_code = taskCode;
      timestamps = timestamps;
      user_id = TextToNat(userId);
      vft_total = TextToNat(vftTotal);
    };
    let recordIndex : Nat = List.size(vftRecordList);
    lastIndex := TextToNat(index);
    updateUserInfo(record, recordIndex);
    vftRecordList := List.push<Types.VftRecord>(record, vftRecordList);
  };

  func getMyUserInfoMap() : HashMap.HashMap<Nat, Types.VftUserInfo> {
    let myUserInfoMap = HashMap.HashMap<Nat, Types.VftUserInfo>(32, Nat.equal, Hash.hash);
    for ((k, v) in userInfoEntry.vals()) {
      myUserInfoMap.put(k, v);
    };
    myUserInfoMap;
  };

  func saveUserInfo(info : HashMap.HashMap<Nat, Types.VftUserInfo>) {
    print("------------------------------");
    // Debug.print(debug_show(userInfoEntry));
    userInfoEntry := Iter.toArray<(Nat, Types.VftUserInfo)>(info.entries());
  };

  func updateUserInfo(record : Types.VftRecord, recordIndex : Nat) : () {
    let myUserInfoMap = getMyUserInfoMap();
    let userId : Nat = record.user_id;
    let value = myUserInfoMap.get(userId);
    var user : ?Types.VftUserInfo = value;
    switch value {
      case (null) {
        myUserInfoMap.put(
          userId,
          {
            details = [recordIndex];
            nft = null;
            task_code = record.task_code;
            userId = record.user_id;
            vft_total = record.vft_total;
            wallet = null;
          },
        );
      };
      case (?value) {
        myUserInfoMap.put(
          userId,
          {
            details = arrayNatAdd(value.details, recordIndex);
            nft = null;
            task_code = record.task_code;
            userId = record.user_id;
            vft_total = record.vft_total +value.vft_total;
            wallet = null;
          },
        );
      };
    };
    saveUserInfo(myUserInfoMap);
  };

  func TextToNat(input : Text) : Nat {
    let result = Nat.fromText(Iter.toArray(Text.split(input, #char '.'))[0]);
    if (result == null) {
      return 0;
    };
    return convert(result);
  };

  public shared func TextToNat2(input : Text) : async Nat {
    let result = Nat.fromText(Iter.toArray(Text.split(input, #char '.'))[0]);
    if (result == null) {
      return 0;
    };
    return convert(result);
  };
  func convert(n : ?Nat) : Nat {
    switch n {
      case (null) { 0 };
      case (?n) { n };
    };
  };

  func arrayNatAdd(array : [Nat], input : Nat) : [Nat] {
    let buffer1 = Buffer.Buffer<Nat>(array.size() +1);
    for (entry in array.vals()) {
      buffer1.add(entry);
    };
    buffer1.add(input);
    Buffer.toArray(buffer1);
  };

};
