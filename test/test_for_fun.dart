import 'dart:async';

zzz(s) async => new Future.delayed(new Duration(seconds: 1), () => s);

a() async {
  var a = await zzz(1);
  var b = await zzz(2);
  return a + b;
}
b() async {
  var a = zzz(1);
  var b = zzz(2);
  return await a + await b;
}
c() async {
  var a = zzz(1);
  var b = zzz(2);
  a = await a;
  b = await b;
  return a + b;
}
d() async {
  var a, b;
  {
    var af = zzz(1);
    var bf = zzz(2);
    a = await af;
    b = await bf;
  }
  return a + b;
}
e() {
  var a = zzz(1);
  var b = zzz(2);
  return Future.wait([a, b]).then((v) => v[0] + v[1]);
}
f() {
  var a, b;
  return Future.wait([
    zzz(1).then((v) => a = v),
    zzz(2).then((v) => b = v),
  ]).then((_) => a + b);
}

g() {
  var a, b;
  f1()=>zzz(1).then((v) => a = v);
  f2()=>zzz(2).then((v) => b = v);
  return Future.forEach([
    f1,
    f2
  ],(f)=>f()).then((_) => a + b);
}
h() async{
  var a = zzz(1);
  var b = zzz(2);
  await Future.wait([a, b]);

  return (await a) + (await b);
}

i() async{
  var a = zzz(1);
  var b = zzz(2);
  await Future.wait([a, b]);

  return (await a) + (await b);
}

run(name, function) {
  var sw = new Stopwatch()..start();
  function().then((v) {
    assert(v == 3);
    sw.stop();
    print('$name() took ${sw.elapsedMilliseconds} ms');
  });
}

main(){
  run('a', a);
  run('b', b);
  run('c', c);
  run('d', d);
  run('e', e);
  run('f', f);
  run('g', g);
  run('h', h);
  run('i', i);
}