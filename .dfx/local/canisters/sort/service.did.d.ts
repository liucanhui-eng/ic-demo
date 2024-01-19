import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface _SERVICE {
  'QuickSortMain' : ActorMethod<[Array<bigint>], Array<bigint>>,
  'feibo' : ActorMethod<[bigint], bigint>,
  'greet' : ActorMethod<[string], string>,
}
