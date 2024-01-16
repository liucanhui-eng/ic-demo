export const idlFactory = ({ IDL }) => {
  return IDL.Service({ 'main' : IDL.Func([], [IDL.Nat], []) });
};
export const init = ({ IDL }) => { return []; };
