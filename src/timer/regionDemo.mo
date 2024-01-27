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

    stable var Record = {
        bytes = Region.new();
        var bytes_count : Nat64 = 0;
        vftRecord = Region.new();
        var elems_count : Nat64 = 0;
        var info : [var [var ?Types.VftUserInfo]] = Array.init<[var ?Types.VftUserInfo]>(1, Array.init<?Types.VftUserInfo>(1000, null));
    };
       let elem_size = 16 : Nat64;
    //根据索引取值
    public func queryRecord(index : Nat64) : async ?Text {
        assert index < Record.elems_count;
        let pos = Region.loadNat64(Record.vftRecord, index * elem_size);
        let size = Region.loadNat64(Record.vftRecord, index * elem_size + 8);
        let elem = { pos; size };
        Text.decodeUtf8(Region.loadBlob(Record.bytes, elem.pos, Nat64.toNat(elem.size)));
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
};
