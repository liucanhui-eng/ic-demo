export const idlFactory = ({ IDL }) => {
  const TokenId = IDL.Nat64;
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
  const Nft = IDL.Record({
    'id' : TokenId,
    'op' : IDL.Text,
    'to' : IDL.Principal,
    'tid' : IDL.Nat,
    'owner' : IDL.Principal,
    'from' : IDL.Principal,
    'meta' : MetadataDesc,
  });
  const VftUserInfo = IDL.Record({
    'nft' : IDL.Opt(Nft),
    'userId' : IDL.Text,
    'details' : IDL.Text,
    'task_code' : IDL.Text,
    'wallet' : IDL.Opt(IDL.Text),
    'vft_total' : IDL.Float64,
  });
  const HttpHeader = IDL.Record({ 'value' : IDL.Text, 'name' : IDL.Text });
  const HttpResponsePayload = IDL.Record({
    'status' : IDL.Nat,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HttpHeader),
  });
  const TransformArgs = IDL.Record({
    'context' : IDL.Vec(IDL.Nat8),
    'response' : HttpResponsePayload,
  });
  const CanisterHttpResponsePayload = IDL.Record({
    'status' : IDL.Nat,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HttpHeader),
  });
  return IDL.Service({
    'TextToNat2' : IDL.Func([IDL.Text], [IDL.Float64], []),
    'cleanAll' : IDL.Func([IDL.Nat, IDL.Nat], [IDL.Text], []),
    'queryLastIndex' : IDL.Func([], [IDL.Nat], ['query']),
    'queryRecordCount' : IDL.Func([], [IDL.Nat], ['query']),
    'queryUserInfoEntry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, VftUserInfo))],
        ['query'],
      ),
    'transform' : IDL.Func(
        [TransformArgs],
        [CanisterHttpResponsePayload],
        ['query'],
      ),
    'work' : IDL.Func([], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
