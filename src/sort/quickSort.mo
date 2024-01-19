import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Array "mo:base/Array";
actor {

  func feb(num:Nat):Nat{
    if (num<=1){
      1
    }else{
      feb(num-1)+feb(num-2)
    }
  };



  public query func QuickSortMain(arr:[Int]):async [Int]{
      let low=0;
      let high= arr.size();
      var newArr:[var Int] = Array.thaw(arr);
      quickSort(newArr,low,high);
      Array.freeze(newArr)
  };

  func quickSort(arr:[var Int],low:Nat,high:Nat){
      if (low < high) {
          var pivotIndex = partition(arr, low, high);
          quickSort(arr, low, pivotIndex - 1);
          quickSort(arr, pivotIndex + 1, high);
      };
  };

func partition(arr:[var Int],low:Nat,high:Nat):Nat{
    let pivot=arr[high];
    var i:Nat = low - 1;
    var index=low;
    while(low < high){
        if (arr[index] < pivot) {
        i+=1;
        swap(arr, i, index);
    };
    index := index+1
  };
  swap(arr, i + 1, high);
  i + 1;
};

// 交换两个下标对应的值
func swap(arr:[var Int],i:Nat,j:Nat){
  let temp=arr[i];
  arr[i] := arr[j];
  arr[j] := temp;
};







  public query func feibo(num : Nat):async Nat{
    feb(num)
  };

  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };
};
