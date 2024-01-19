export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'QuickSortMain' : IDL.Func(
        [IDL.Vec(IDL.Int)],
        [IDL.Vec(IDL.Int)],
        ['query'],
      ),
    'feibo' : IDL.Func([IDL.Nat], [IDL.Nat], ['query']),
    'greet' : IDL.Func([IDL.Text], [IDL.Text], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
