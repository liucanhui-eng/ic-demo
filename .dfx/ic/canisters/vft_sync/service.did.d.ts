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
  'querUserInfo' : ActorMethod<[bigint], [] | [string]>,
  'queryRecord' : ActorMethod<[bigint], [] | [string]>,
  'queryVftTotal' : ActorMethod<[bigint], [] | [string]>,
  'transform' : ActorMethod<[TransformArgs], CanisterHttpResponsePayload>,
}
