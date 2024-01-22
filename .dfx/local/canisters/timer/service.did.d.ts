import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface CanisterHttpResponsePayload {
  'status' : bigint,
  'body' : Uint8Array | number[],
  'headers' : Array<HttpHeader>,
}
export interface HttpHeader { 'value' : string, 'name' : string }
export interface HttpResponsePayload {
  'status' : bigint,
  'body' : Uint8Array | number[],
  'headers' : Array<HttpHeader>,
}
export type MetadataDesc = Array<MetadataPart>;
export interface MetadataKeyVal { 'key' : string, 'val' : MetadataVal }
export interface MetadataPart {
  'data' : Uint8Array | number[],
  'key_val_data' : Array<MetadataKeyVal>,
  'purpose' : MetadataPurpose,
}
export type MetadataPurpose = { 'Preview' : null } |
  { 'Rendered' : null };
export type MetadataVal = { 'Nat64Content' : bigint } |
  { 'Nat32Content' : number } |
  { 'Nat8Content' : number } |
  { 'NatContent' : bigint } |
  { 'Nat16Content' : number } |
  { 'BlobContent' : Uint8Array | number[] } |
  { 'TextContent' : string };
export interface Nft {
  'id' : TokenId,
  'op' : string,
  'to' : Principal,
  'tid' : bigint,
  'owner' : Principal,
  'from' : Principal,
  'meta' : MetadataDesc,
}
export type TokenId = bigint;
export interface TransformArgs {
  'context' : Uint8Array | number[],
  'response' : HttpResponsePayload,
}
export interface VftUserInfo {
  'nft' : [] | [Nft],
  'userId' : string,
  'details' : string,
  'task_code' : string,
  'wallet' : [] | [string],
  'vft_total' : number,
}
export interface _SERVICE {
  'TextToNat2' : ActorMethod<[string], number>,
  'cleanAll' : ActorMethod<[bigint, bigint], string>,
  'queryLastIndex' : ActorMethod<[], bigint>,
  'queryRecordCount' : ActorMethod<[], bigint>,
  'queryUserInfoEntry' : ActorMethod<[], Array<[string, VftUserInfo]>>,
  'transform' : ActorMethod<[TransformArgs], CanisterHttpResponsePayload>,
  'work' : ActorMethod<[], undefined>,
}
