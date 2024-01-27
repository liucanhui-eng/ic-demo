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
    'querUserInfo' : IDL.Func([IDL.Nat], [IDL.Opt(IDL.Text)], []),
    'queryRecord' : IDL.Func([IDL.Nat64], [IDL.Opt(IDL.Text)], []),
    'queryVftTotal' : IDL.Func([IDL.Nat], [IDL.Opt(IDL.Text)], []),
    'transform' : IDL.Func(
        [TransformArgs],
        [CanisterHttpResponsePayload],
        ['query'],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
