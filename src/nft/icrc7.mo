import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import List "mo:base/List";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Types "./Types";
import Debug "mo:base/Debug";

shared actor class ICRC7NFT(custodian: Principal, init : Types.ICRC7NonFungibleToken) = Self {
   //       初始事务ID
  stable var transactionId: Types.TransactionId = 0;
  // 初始 nft货币值为空
  stable var nfts = List.nil<Types.Nft>();
  // 初始化 custodians 数组
  // 数组中存放的元素是 Principal
  stable var custodians = List.make<Principal>(custodian);
  // 初始化 logo 图片
  stable var logo : Types.LogoResult = init.logo;
  // 初始化 name 名称
  stable var name : Text = init.name;
  stable var symbol : Text = init.symbol;
  // 初始化 最大发行量
  stable var maxLimit : Nat16 = init.maxLimit;
// 创建一个新的主体 aaaaa-aa
  let null_address : Principal = Principal.fromText("aaaaa-aa");

   public  func logtest():async Text{
    Debug.print("hello world");
    "xxxx"
   };
   public shared({ caller }) func mintICRC7(user: Principal, metadata: Types.MetadataDesc,walletAddress:Text) : async Types.MintReceipt {

    Debug.print(debug_show (caller));
    Debug.print(debug_show (custodians));
    Debug.print(debug_show (nfts));
    Debug.print(debug_show ("------------------------------------"));

    if (not List.some(custodians, func (custodian : Principal) : Bool { custodian == caller })) {
      return #Err(#Unauthorized);
    };
    let newId = Nat64.fromNat(List.size(nfts));
    let nft : Types.Nft = {
      from = user;
      id = newId;
      meta = metadata;
      op= "7mint";
      owner = user;
      tid=transactionId;
      to=user;
    };
    nfts := List.push(nft, nfts);
    transactionId += 1;
    return #Ok({
      user = user;
      nft = nft;
    });
  };
}