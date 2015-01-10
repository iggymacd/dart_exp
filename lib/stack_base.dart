import 'package:polymer/polymer.dart';
import 'dart:html';
import 'card_foundation.dart';

/**
 * A Polymer stack base element.
 */
@CustomTag('stack-base')
class StackBase extends PolymerElement {
  @published int count = 0;
  @published List<Card> cards;
  @published List<Foundation> foundations;
  List<CardFoundation> foundationElements;

  StackBase.created() : super.created() {
    cards = toObservable([new Card('k','spades',top:5,left:5),
             new Card('q','spades',top:15,left:15),
             new Card('j','spades',top:25,left:25),
             new Card('t','spades',top:35,left:35),
             new Card('9','s',top:45,left:45)]);
    foundations = [new Foundation(),
             new Foundation(),
             new Foundation(),
             new Foundation(),
             new Foundation()];
  }
  void layoutReady(Event e, var details, Node node) {
    CardFoundation cf2;
    
    //cf2.
    //node.onFullscreenChange.listen((data) => print('data is $data'));
      print('node is $node');
//      var observer = new MutationObserver((mutations, _) {
//            mutations.forEach((mutation) {
//              print(
//                '[mutation] ' +
//                mutation.attributeName +
//                ' is now: ' +
//                mutation.target.attributes[mutation.attributeName]
//              );
//            });
//          });
//          observer.observe(node, attributes: false);    
          
  }
  
  void attached() {
    super.attached();
    window.addEventListener('resize', (e) => print('test $e'));
//    var foundations = $['0'];
//    print('stacks $foundations');
//    startButton = $['startButton'];
//    stopButton = $['stopButton'];
//    resetButton = $['resetButton'];
//        
//    stopButton.disabled = true;
//    resetButton.disabled = true;
  }
  void increment() {
    count++;
  }
  void onFoundationClicked(CustomEvent event, detail, target) {
    print('in onCardClicked...');
    CardFoundation cf;
    DivElement de;
    //de.
    //cf.propertyForAttribute('top');
    //cf.parent.getBoundingClientRect().left
    var f = target;
    cards.forEach((card) {
      print('f.documentOffset.x is ${f.documentOffset.x} and f.documentOffset.y is ${f.documentOffset.y}');
      print('f.parent.getBoundingClientRect().left is ${f.parent.getBoundingClientRect().left} and f.parent.getBoundingClientRect().top is ${f.parent.getBoundingClientRect().top}');
      print('f.getBoundingClientRect().left is ${f.getBoundingClientRect().left} and f.getBoundingClientRect().top is ${f.getBoundingClientRect().top}');
      print('f.offset.left is ${f.offset.left} and f.offset.top is ${f.offset.top}');
      card.left = f.getBoundingClientRect().left +15;
      card.top =  f.getBoundingClientRect().top;
          });
    print('foundation is ${f.position} at ${f.documentOffset}');
  }
  void onCardClicked(CustomEvent event, detail, target) {
    print('in onCardClicked...');
    var p = target;
    print('card is ${p.rank} of ${p.suit} and is at ${p.getBoundingClientRect().left} and ${p.getBoundingClientRect().top}');
    print('card parent is at ' +
          '${p.parent.getBoundingClientRect().left}' +
          ' and ${p.parent.getBoundingClientRect().top} and parent parent is ' +
        '${p.parent.parent.getBoundingClientRect().left}' +
        ' and ${p.parent.parent.getBoundingClientRect().top}');
  }
//  void onDoubleClicked(CustomEvent event, detail, target) {
//    print('in onDoubleClicked...');
//  }

}

class Foundation{
  num top;
  num left;
  Foundation({this.top:0,this.left:0});
}


class Card extends Observable{
  String suit;
  String rank;
  @observable
  num top;
  @observable
  num left;
  Card(this.rank,this.suit,{this.top:0,this.left:0});
}