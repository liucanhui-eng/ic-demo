export const idlFactory = ({ IDL }) => {
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
    'queryDetails222' : IDL.Func([IDL.Text], [IDL.Opt(IDL.Text)], []),
    'queryLastIndex' : IDL.Func([], [IDL.Text], ['query']),
    'queryRecord' : IDL.Func([IDL.Nat64], [IDL.Opt(IDL.Text)], []),
    'queryRecordCount' : IDL.Func([], [IDL.Nat64], []),
    'queryUserVftTotal' : IDL.Func([IDL.Text], [IDL.Opt(IDL.Text)], []),
    'resetArrayCount' : IDL.Func([], [IDL.Nat], []),
    'transform' : IDL.Func(
        [TransformArgs],
        [CanisterHttpResponsePayload],
        ['query'],
      ),
    'work' : IDL.Func([], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
