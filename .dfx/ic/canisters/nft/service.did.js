export const idlFactory = ({ IDL }) => {
  const MetadataVal = IDL.Variant({
    'Nat64Content' : IDL.Nat64,
    'Nat32Content' : IDL.Nat32,
    'Nat8Content' : IDL.Nat8,
    'NatContent' : IDL.Nat,
    'Nat16Content' : IDL.Nat16,
    'BlobContent' : IDL.Vec(IDL.Nat8),
    'TextContent' : IDL.Text,
  });
  const MetadataKeyVal = IDL.Record({ 'key' : IDL.Text, 'val' : MetadataVal });
  const MetadataPurpose = IDL.Variant({
    'Preview' : IDL.Null,
    'Rendered' : IDL.Null,
  });
  const MetadataPart = IDL.Record({
    'data' : IDL.Vec(IDL.Nat8),
    'key_val_data' : IDL.Vec(MetadataKeyVal),
    'purpose' : MetadataPurpose,
  });
  const MetadataDesc = IDL.Vec(MetadataPart);
  const TokenId = IDL.Nat64;
  const Nft = IDL.Record({
    'id' : TokenId,
    'op' : IDL.Text,
    'to' : IDL.Principal,
    'tid' : IDL.Nat,
    'owner' : IDL.Principal,
    'from' : IDL.Principal,
    'meta' : MetadataDesc,
  });
  const MintReceiptPart = IDL.Record({ 'nft' : Nft, 'user' : IDL.Principal });
  const ApiError = IDL.Variant({
    'ZeroAddress' : IDL.Null,
    'InvalidTokenId' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'Other' : IDL.Null,
  });
  const MintReceipt = IDL.Variant({ 'Ok' : MintReceiptPart, 'Err' : ApiError });
  const ICRC7NFT = IDL.Service({
    'logtest' : IDL.Func([], [IDL.Text], []),
    'mintICRC7' : IDL.Func(
        [IDL.Principal, MetadataDesc, IDL.Text],
        [MintReceipt],
        [],
      ),
  });
  return ICRC7NFT;
};
export const init = ({ IDL }) => { return []; };
