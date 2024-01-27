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
export interface TransformArgs {
  'context' : Uint8Array | number[],
  'response' : HttpResponsePayload,
}
export interface _SERVICE {
  'queryDetails222' : ActorMethod<[string], [] | [string]>,
  'queryLastIndex' : ActorMethod<[], string>,
  'queryRecord' : ActorMethod<[bigint], [] | [string]>,
  'queryRecordCount' : ActorMethod<[], bigint>,
  'queryUserVftTotal' : ActorMethod<[string], [] | [string]>,
  'transform' : ActorMethod<[TransformArgs], CanisterHttpResponsePayload>,
  'work' : ActorMethod<[], undefined>,
}
