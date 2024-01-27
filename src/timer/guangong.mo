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

    //链上数据结构对象
    stable var Record = {
        bytes = Region.new();
        var bytes_count : Nat64 = 0;
        vftRecord = Region.new();
        var elems_count : Nat64 = 0;
        var info : [var [var ?Types.VftUserInfo]] = Array.init<[var ?Types.VftUserInfo]>(1, Array.init<?Types.VftUserInfo>(1000, null));
    };
    //最新的记录ID
    stable var lastIndex : Text = "0";

    //同步任务ID
    stable var timerId : Nat = 0;
    //二维数组坐标
    type infoIndex = {
        page : Nat;
        index : Nat;
    };
    //
    let elem_size = 16 : Nat64;
    //根据索引取值
    public func queryRecord(index : Nat64) : async ?Text {
        assert index < Record.elems_count;
        let pos = Region.loadNat64(Record.vftRecord, index * elem_size);
        let size = Region.loadNat64(Record.vftRecord, index * elem_size + 8);
        let elem = { pos; size };
        Text.decodeUtf8(Region.loadBlob(Record.bytes, elem.pos, Nat64.toNat(elem.size)));
    };

    // for test
    public func querUserInfo(userId : Nat) : async ?Text {
        let u = getUser(?userId);
        switch (u) {
            case (null) { return null };
            case (?u) { return ?u.vft_total_statements };
        };
    };

    //query vft total
    public func queryVftTotal(userId : Nat) : async ?Text {
        let u = getUser(?userId);
        switch (u) {
            case (null) { return null };
            case (?u) {
                var total : Float = 0;
                for (item in Text.split(u.vft_total_statements, #char ',')) {
                    total += textToFloat(item);
                };
                return ?Float.toText(total);
            };
        };
    };
    func addRecord(input : Text) : Nat64 {
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
    //扩容region
    func regionEnsureSizeBytes(r : Region, new_byte_count : Nat64) {
        let pages = Region.size(r);
        if (new_byte_count > pages << 16) {
            let new_pages = ((new_byte_count + ((1 << 16) - 1)) / (1 << 16)) -pages;
            assert Region.grow(r, new_pages) == pages;
        };
    };
    // 添加用户
    func addUser(user : Types.VftUserInfo, userId : ?Nat) : () {
        switch (userId) {
            case (null) {
                print("非法的userID");
            };
            case (?userId) {
                let index = getInfoIndex(userId);
                expansionArray(userId);
                Record.info[index.page][index.index] := ?user;
            };
        };
    };
    //获取坐标
    func getInfoIndex(input : Nat) : infoIndex {
        {
            page = getPage(input);
            index = getIndex(input);
        };
    };
    //根据userID查询用户
    func getUser(userId : ?Nat) : ?Types.VftUserInfo {
        print("---------------");
        switch (userId) {
            case (null) { null };
            case (?userId) {
                let index = getInfoIndex(userId);
                print("---------------1111");
                return Record.info[index.page][index.index];
            };
        };
    };

    //根据坐标查询用户
    func doGetData(index : infoIndex) : ?Types.VftUserInfo {
        return Record.info[index.page][index.index];
    };
    //获取索引
    func getIndex(userId : Nat) : Nat {
        var index : Nat = userId % 1000;
        index;
    };
    //获取分页
    func getPage(userId : Nat) : Nat {
        var page : Nat = userId / 1000;
        page;
    };
    //扩容数组
    func expansionArray(userId : Nat) : () {
        assert (userId < (1000 * (Record.info.size() +10)));
        print("======================================扩容" #Nat.toText(userId));
        print("======================================扩容" #Nat.toText(1000 * Record.info.size()));
        if ((userId +1) >= 1000 * Record.info.size()) {
            print("======================================扩容");
            Record.info := doExpansionArray(Record.info);
        };
    };
    //do扩容数组
    func doExpansionArray(array : [var [var ?Types.VftUserInfo]]) : [var [var ?Types.VftUserInfo]] {
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

    //处理返回数据
    func doWork() : async Bool {
        let httpResp = await do_send_post(lastIndex);
        if (httpResp == "-1") {
            print("查询结束！！！！");
            return false;
        };
        let lines = Text.split(httpResp, #char ';');
        lastIndex := Option.get(lines.next(), "0");
        for (outerElement in lines) {
            let index = addRecord(outerElement);
            buildRecord(outerElement, index);
        };
        // print("开始更新数据【更新后数据】");
        // Debug.print(debug_show (userInfoEntry));
        Debug.print(debug_show ("处理完成。开始下一次循环" # Nat64.toText(Record.elems_count)));
        return true;
    };
    //
    func buildRecord(line : Text, recordIndex : Nat64) : () {
        //5409;2636,register,60,2024-01-15 06:50:05
        let array = Iter.toArray(Text.split(line, #char ','));
        let userId = array[0];
        let taskCode = array[1];
        let vftTotal = array[2];
        updateUserInfo(userId, vftTotal, taskCode, recordIndex);
    };
    //文本转 float
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
                };
            };
        };
        return f;
    };

    //更新用户信息
    func updateUserInfo(userId : Text, vft_total : Text, taskCode : Text, index : Nat64) : () {
        print("开始解析返回结果" # userId);
        let userIdNat = Nat.fromText(userId);
        let user = getUser(userIdNat);
        switch (user) {
            case (null) {
                addUser(buildUserInfo(taskCode, userId, vft_total, index), userIdNat);
            };
            case (?user) {
                user.vft_total_statements := user.vft_total_statements # "," # vft_total;
                user.details := user.details # "," # Nat64.toText(index);
            };
        };
    };
    //构建用户对象
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

    func do_send_post(lastIndex : Text) : async Text {
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

    //查询数据接口
    private func outCall() : async () {
        print("定时查询服务启动,记录数{}" # Nat64.toText(Record.elems_count));
        let _continue = await doWork();
        if (not _continue) {
            print("关闭定时查询服务" # Nat.toText(timerId));
            cancelTimer(timerId);
        };
    };
    // 重启定时服务
    private func resetQuery() : async () {
        print("重新启动定时服务");
        timerId := recurringTimer(#seconds 60, outCall);
    };
    //定时服务
    timerId := recurringTimer(#seconds 60, outCall);
    recurringTimer(#seconds(60 * 60 * 24), resetQuery);
};
