//import 'package:scheduled_test/scheduled_test.dart';
//import 'dart:async';
//
//
//main() async{
//  //futureOne().then((_)=>futureTwo(_));
//  futureTwo( await futureOne());
//}
//
//futureTwo(val ) {
//  print(val);
//}
//
//Future futureOne(){
//  return new Future.value(5);
//}

import 'dart:async';

main() async {
  print(await f());
}

f() async {
   var a = await g(42);
   var b = await g(4711);
   return a + b;
}

g(n) {
  print(n);
  return n;
}