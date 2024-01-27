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
import Region "mo:base/Region";
import { setTimer; recurringTimer; cancelTimer } = "mo:base/Timer";
import Nat16 "mo:base/Nat16";
import Random "mo:base/Random";
import Option "mo:base/Option";

actor {
  let oneSecond = 1_000_000_000; // nanoseconds
  let tenSecond = 1_000_000_000_0; // nanoseconds

  stable var Record = {
    bytes = Region.new();
    var bytes_count : Nat64 = 0;
    vftRecord = Region.new();
    var elems_count : Nat64 = 0;
    // var userInfoList = List.nil<Types.VftUserInfo>();
    var info : [var [var ?Types.VftUserInfo]] = Array.init<[var ?Types.VftUserInfo]>(1, Array.init<?Types.VftUserInfo>(1000, null));
  };

  type zuobiao = {
    page : Nat;
    index : Nat;
  };
  stable var testData : Text = "-1";
  stable var testUserId : Nat = 0;

  // public type Elem = {
  //   pos : Nat64;
  //   size : Nat64;
  // };
  let elem_size = 16 : Nat64; /* two Nat64s, for pos and size. */

  public func queryRecordCount() : async Nat64 {
    // let firstList = List.get<List.List<Types.VftUserInfo>>(Record.userInfoList2,0);
    Record.elems_count;
  };
  public func queryUserVftTotal(userId : Text) : async ?Text {
    ?"  ";
  };
  public func queryDetails222(userId : Text) : async ?Text {
    ?"";
  };



  public func queryRecord(index : Nat64) : async ?Text {
    assert index < Record.elems_count;
    let pos = Region.loadNat64(Record.vftRecord, index * elem_size);
    let size = Region.loadNat64(Record.vftRecord, index * elem_size + 8);
    let elem = { pos; size };
    Text.decodeUtf8(Region.loadBlob(Record.bytes, elem.pos, Nat64.toNat(elem.size)));
  };
  func add(input : Text) : Nat64 {
    let blob = Text.encodeUtf8(input);
    let elem_i = Record.elems_count;
    Record.elems_count += 1;

    let elem_pos = Record.bytes_count;
    Record.bytes_count += Nat64.fromNat(blob.size());

    regionEnsureSizeBytes(Record.bytes, Record.bytes_count);
    Region.storeBlob(Record.bytes, elem_pos, blob);

    regionEnsureSizeBytes(Record.vftRecord, Record.elems_count * elem_size);
    Region.storeNat64(Record.vftRecord, elem_i * elem_size + 0, elem_pos);
    Region.storeNat64(Record.vftRecord, elem_i * elem_size + 8, Nat64.fromNat(blob.size()));
    elem_i;
  };

  // stable var vftRecordList : [Types.VftRecord] = [];
  stable var lastIndex : Text = "0";
  stable var errorList = List.nil<Text>();
  stable var timerId : Nat = 0;
  //var myUserInfoMap = HashMap.fromIter<Text,Text>(entries.vals(), 32, Text.equal, Text.hash);

  // stable let myUserInfoMap : HashMap.HashMap<Text, Text> = HashMap.HashMap(32, Text.equal, Hash.hash);

  // send a request get vft info

  let daySeconds = 24 * 60 * 60;

  let tenMin = 10 * 60;

  let oneMin = 5;

  public func work() : async () {

    print("开始更新数据【更新前数据】=====================================================");
    // print("开始更新数据【更新前数据】");

    // Debug.print(debug_show (userInfoEntry));
    // Debug.print(debug_show (vftRecordList));

    var working : Bool = true;
    // while (working) {
    //let result = await do_send_post();
    working := doWork("-1");
    // };
  };

  func doWork(httpResp : Text) : Bool {
    print("开始解析返回结果");
    if (httpResp == "-1") {
      return false;
    };
    let lines = Text.split(httpResp, #char ';');
    var start = false;
    for (outerElement in lines) {
      if (outerElement.size() > 0 and start) {
        let index = add(outerElement);
        buildRecord(outerElement, index);
      };
      start := true;
    };
    // print("开始更新数据【更新后数据】");
    // Debug.print(debug_show (userInfoEntry));
    Debug.print(debug_show ("处理完成。开始下一次循环" # Nat64.toText(Record.elems_count)));
    return true;
  };
  func regionEnsureSizeBytes(r : Region, new_byte_count : Nat64) {
    let pages = Region.size(r);
    if (new_byte_count > pages << 16) {
      let new_pages = ((new_byte_count + ((1 << 16) - 1)) / (1 << 16)) -pages;
      assert Region.grow(r, new_pages) == pages;
    };
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
      { name = "index"; value = lastIndex },
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

  public query func queryLastIndex() : async Text {
    lastIndex;
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

  func buildRecord(line : Text, recordIndex : Nat64) : () {
    print("开始解析返回结果2");
    let array = Iter.toArray(Text.split(line, #char ','));
    let index = array[0];
    let userId = array[1];
    let taskCode = array[2];
    let vftTotal = array[3];
    lastIndex := index;
    print("更新recordIndex " #index);
    updateUserInfo(Nat.toText(testUserId), vftTotal, taskCode, recordIndex);
  };

  func updateUserInfo(userId : Text, vft_total : Text, taskCode : Text, index : Nat64) : () {
    print("开始解析返回结果" # userId);
    testUserId += 1;

    let user = getUser(testUserId);
    let user1 = Option.get(user, null);

    switch (user) {
      case (null) {
        addUser(buildUserInfo(taskCode, userId, vft_total, index), testUserId);
      };
      case (?user) {
        user.vft_total_statements := user.vft_total_statements # "," # vft_total;
        user.details := user.details # "," # Nat64.toText(index);
      };
    };
  };

  func buildUserInfo(taskCode : Text, userId : Text, vft_total : Text, index : Nat64) : Types.VftUserInfo {
    let user = {
      var details = Nat64.toText(index);
      nft = null;
      task_code = taskCode;
      userId = userId;
      vft_total = null;
      var vft_total_statements = vft_total;
      wallet = null;
    };
    user;
  };

  func addUser(user : Types.VftUserInfo, userId : Nat) : () {
    let zb = getZuobiao(userId);
    kuorong(testUserId);
    Record.info[zb.page][zb.index] := ?user;
  };

  func getZuobiao(input : Nat) : zuobiao {
    let page = getPage(input);
    {
      page = page;
      index = getIndex(input);
    };
  };

  func getUser(input : Nat) : ?Types.VftUserInfo {
    let zb = getZuobiao(input);
    return Record.info[zb.page][zb.index];
  };

  func doGetData(zb : zuobiao) : ?Types.VftUserInfo {
    return Record.info[zb.page][zb.index];
  };

  func getIndex(userId : Nat) : Nat {
    var index : Nat = userId % 1000;
    index;
  };
  func getPage(userId : Nat) : Nat {
    var page : Nat = userId / 1000;
    page;
  };
  func kuorong(userId : Nat) : () {
    assert (userId < (1000 * (Record.info.size() +10)));
     print("======================================扩容"#Nat.toText(userId));
     print("======================================扩容"#Nat.toText(1000 * Record.info.size()));
    if ((userId+1) >= 1000 * Record.info.size()) {
      print("======================================扩容");
      Record.info := doKuorong(Record.info);
    };
  };
  func doKuorong(array : [var [var ?Types.VftUserInfo]]) : [var [var ?Types.VftUserInfo]] {
    let buffer = Buffer.Buffer<[var ?Types.VftUserInfo]>(array.size() +10);
    let newArray : [var [var ?Types.VftUserInfo]] = Array.init<[var ?Types.VftUserInfo]>(10, Array.init<?Types.VftUserInfo>(1000, null));
    for (entry in array.vals()) {
      buffer.add(entry);
    };
    for (entry in newArray.vals()) {
      buffer.add(entry);
    };
    return Array.thaw(Buffer.toArray<[var ?Types.VftUserInfo]>(buffer));
  };

  private func outCall() : async () {
    print("定时查询服务启动,记录数{}" # Nat64.toText(Record.elems_count));
    if (testData == "-1") {
      testData := await do_send_post();

    };
    lastIndex := "0";
    let q = doWork(testData);
    if (not q) {
      print("关闭定时查询服务" # Nat.toText(timerId));
      cancelTimer(timerId);
    };
  };
  private func resetQuery() : async () {
    print("重新启动定时服务");
    timerId := recurringTimer(#seconds tenMin, outCall);
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
      ignore recurringTimer(#seconds oneMin, outCall);
    },
  );
};
