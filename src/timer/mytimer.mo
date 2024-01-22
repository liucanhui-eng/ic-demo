import { print } = "mo:base/Debug";
import HttpTypes "HttpTypes";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
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
import Float "mo:base/Float";
import Char "mo:base/Char";
import Int64 "mo:base/Int64";
import { abs } = "mo:base/Int";
import { now } = "mo:base/Time";
import { setTimer; recurringTimer; cancelTimer } = "mo:base/Timer";

actor {
  let oneSecond = 1_000_000_000; // nanoseconds
  let tenSecond = 1_000_000_000_0; // nanoseconds

  // private func printHello() : async () {

  //   print("Hello, World!");
  // };

  // ignore recurringTimer(#seconds hour24, work);
  // save data
  stable var userInfoEntry : [(Text, Types.VftUserInfo)] = [];

  // stable var vftRecordList : [Types.VftRecord] = [];
  stable var lastIndex : Nat = 0;
  stable var vftRecordList = List.nil<Types.VftRecord>();
  stable var errorList = List.nil<Text>();
  stable var timerId : Nat = 0;


  //var myUserInfoMap = HashMap.fromIter<Text,Text>(entries.vals(), 32, Text.equal, Text.hash);

  // stable let myUserInfoMap : HashMap.HashMap<Text, Text> = HashMap.HashMap(32, Text.equal, Hash.hash);

  // send a request get vft info

  let daySeconds = 24 * 60 * 60;

  let tenMin = 2 * 60;

  public func work() : async () {

    print("开始更新数据【更新前数据】=====================================================");
    // print("开始更新数据【更新前数据】");

    // Debug.print(debug_show (userInfoEntry));
    // Debug.print(debug_show (vftRecordList));

    var working : Bool = true;
    // while (working) {
    let result = await do_send_post();
    working := doWork(result);
    // };
  };

  func doWork(httpResp : Text) : Bool {
    print("开始解析返回结果");
    if (httpResp == "-1") {
      return false;
    };
    //3000次运算
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
    return true;
  };

  func do_send_post() : async Text {
    print("发送http请求");
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
    result;
  };

  public query func queryLastIndex() : async Nat {
    lastIndex;
  };
  public shared func cleanAll(index : Nat, pwd : Nat) : async Text {

    if (pwd != 123456) {
      return "清除失败。身份验证出错";
    };

    lastIndex := index;
    userInfoEntry := [];
    vftRecordList := List.nil<Types.VftRecord>();
    "清除成功";
  };

  public query func queryUserInfoEntry() : async [(Text, Types.VftUserInfo)] {
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
    print("开始解析返回结果2");
    //index,user_id,task_code,vft_total,timestamps
    //3000 * 5=15000
    let array = Iter.toArray(Text.split(line, #char ','));
    let index = array[0];
    let userId = array[1];
    let taskCode = array[2];
    let vftTotal = array[3];
    let timestamps = array[4];
    let record : Types.VftRecord = {
      index = index;
      task_code = taskCode;
      timestamps = timestamps;
      user_id = userId;
      vft_total = textToFloat(vftTotal);
    };
    let recordIndex : Nat = List.size(vftRecordList);
    print("更新recordIndex " #index);
    lastIndex := TextToNat(index);
    updateUserInfo(record, recordIndex);
    vftRecordList := List.push<Types.VftRecord>(record, vftRecordList);
  };

  func getMyUserInfoMap() : HashMap.HashMap<Text, Types.VftUserInfo> {
    let myUserInfoMap = HashMap.HashMap<Text, Types.VftUserInfo>(32, Text.equal, Text.hash);
    for ((k, v) in userInfoEntry.vals()) {
      myUserInfoMap.put(k, v);
    };
    myUserInfoMap;
  };

  func saveUserInfo(info : HashMap.HashMap<Text, Types.VftUserInfo>) {
    // Debug.print(debug_show(userInfoEntry));
    userInfoEntry := Iter.toArray<(Text, Types.VftUserInfo)>(info.entries());
  };

  func updateUserInfo(record : Types.VftRecord, recordIndex : Nat) : () {
    print("开始解析返回结果333");
    let myUserInfoMap = getMyUserInfoMap();
    let userId : Text = record.user_id;
    let value = myUserInfoMap.get(userId);
    var user : ?Types.VftUserInfo = value;
    switch value {
      case (null) {
        myUserInfoMap.put(
          userId,
          {
            details = Nat.toText(recordIndex);
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
            details = value.details # "," #Nat.toText(recordIndex);
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

  func textToFloat(t : Text) : Float {

    var i : Float = 1;
    var f : Float = 0;
    var isDecimal : Bool = false;

    for (c in t.chars()) {
      if (Char.isDigit(c)) {
        let charToNat : Nat64 = Nat64.fromNat(Nat32.toNat(Char.toNat32(c) -48));
        let natToFloat : Float = Float.fromInt64(Int64.fromNat64(charToNat));
        if (isDecimal) {
          let n : Float = natToFloat / Float.pow(10, i);
          f := f + n;
        } else {
          f := f * 10 + natToFloat;
        };
        i := i + 1;
      } else {
        if (Char.equal(c, '.') or Char.equal(c, ',')) {
          f := f / Float.pow(10, i); // Force decimal
          f := f * Float.pow(10, i); // Correction
          isDecimal := true;
          i := 1;
        } else {
          errorList := List.push<Text>(t, errorList);
        };
      };
    };
    return f;
  };

  public shared func TextToNat2(input : Text) : async Float {
    textToFloat(input);
  };
  func convert(n : ?Nat) : Nat {
    switch n {
      case (null) { 0 };
      case (?n) { n };
    };
  };

  // func arrayNatAdd(array : [Text], input : Text) : [Text] {
  //   let buffer1 = Buffer.Buffer<Text>(array.size() +1);
  //   for (entry in array.vals()) {
  //     buffer1.add(entry);
  //   };
  //   buffer1.add(input);
  //   Buffer.toArray(buffer1);
  // };

  private func outCall() : async () {
    print("定时查询服务启动");
    let result = await do_send_post();
    let q = doWork(result);
    if (not q) {
      print("关闭定时查询服务");
      cancelTimer(timerId);
    };
  };
  private func resetQuery() : async () {
    print("重新启动定时服务");
    ignore recurringTimer(#seconds tenMin, outCall);
  };
  ignore setTimer(
    #seconds(daySeconds - abs(now() / 1_000_000_000) % daySeconds),
    func() : async () {
      ignore recurringTimer(#seconds daySeconds, resetQuery);
    },
  );

  timerId := setTimer(
    #seconds(1),
    func() : async () {
      ignore recurringTimer(#seconds tenMin, outCall);
    },
  );
};
