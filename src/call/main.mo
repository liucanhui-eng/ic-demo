import Nft "canister:nft";
import Principal "mo:base/Principal";
import List "mo:base/List";
import Blob "mo:base/Blob";
import Types "../nft/Types";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import nft "../nft/icrc7";


type VFTParams = {
  count: Nat64;
  updateTime: Nat32;
  info: Text;
};

actor {
  public func main(user:Principal,STBCardImage:Blob,SBTMembershipCategory:Text,VFT:VFTParams,SBTGetTime:Nat32,userId: Text,walletAddress:Text) : async Types.MintReceipt {
        let meat:Types.MetadataPart={
            data = Blob.fromArray([97, 98, 99]);
            key_val_data:[Types.MetadataKeyVal]=[
                {key="STBCardImage";val=#BlobContent(STBCardImage)},
                {key="VFTInfo";val=#TextContent(VFT.info)},
                {key="VFTCount";val=#Nat64Content(VFT.count)},
                {key="VFTUpdateTime";val=#Nat32Content(VFT.updateTime)},
                {key="userId";val=#TextContent(userId)},
                {key="walletAddress";val=#TextContent(walletAddress)}
            ];
            purpose :Types.MetadataPurpose= #Preview;
        };
        let metadataArray:[Types.MetadataPart]=[meat];
        let desc:Types.MetadataDesc=metadataArray;
        // var result=await Nft.mintICRC7(user,desc,"xxxx");
        let NFT:nft.ICRC7NFT=actor(Principal.toText(Principal.fromActor(Nft)));
        var result=await NFT.mintICRC7(user,desc,"xxxxx");
        Debug.print(debug_show (result));
        result;
    };
};