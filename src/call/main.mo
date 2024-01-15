import Nft "canister:nft";
import Principal "mo:base/Principal";
import List "mo:base/List";
import Blob "mo:base/Blob";
import Types "../nft/Types";
actor {
    public func main() : async Nat {
        let user=Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai");

        let meat:Types.MetadataPart={
            data = Blob.fromArray([97, 98, 99]);
            key_val_data:[Types.MetadataKeyVal]=[{key="test";val=#TextContent("xxx")}];
            purpose :Types.MetadataPurpose= #Preview;
        };
        let metadataArray:[Types.MetadataPart]=[meat];
        let desc:Types.MetadataDesc=metadataArray;

        var result=await Nft.mintICRC7(user,desc,"xxxx");
        1;
    };
};