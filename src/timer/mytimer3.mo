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
  stable var timerId : Nat = 1;
  var tenMin = 5;
  var tenMin2 = 10;
  let daySeconds = 24 * 60 * 60;

  private func outCall() : async () {
    let aaa="a,b,c,d";
    let lines = Text.split(aaa, #char ',');
    let text=lines.next();
    for(l in lines){
        print("-------------------------------"#l);
    };
    print("out call -------------");
  };

  private func outCall2() : async () {
    cancelTimer(timerId);
  };
  // private func resetQuery() : async () {
  //   print("重新启动定时服务");
  //   timerId := recurringTimer(#seconds tenMin, outCall);
  // };
  // ignore setTimer(
  //   #seconds(daySeconds - abs(now() / 1_000_000_000) % daySeconds),
  //   func() : async () {
  //     timerId:= recurringTimer(#seconds daySeconds, resetQuery);
  //   },

  timerId := recurringTimer(#seconds tenMin, outCall);

  recurringTimer(#seconds tenMin2, outCall2);
};
