library testing;
import 'package:scheduled_test/scheduled_test.dart';
import 'dart:async';
import '../packages/stream_ext/stream_ext.dart';
import '../packages/frappe/frappe.dart';

const List suits = const ['h', 's', 'd', 'c'];
const List ranks = const [
    'a',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    't',
    'j',
    'q',
    'k'];

main() {
  List cards;
  List shuffledCards;
  List cardValues;
  List shuffledCardValues;
  setUp(() {
    cards = [];
    //traditional approach
    for (var rank in ranks) {
      for (var suit in suits) {
        cards.add(new Card(rank, suit));
      }
    }
    cardValues = [];
    //traditional approach
    for (var rank in ranks) {
      for (var suit in suits) {
        cardValues.add('$rank$suit');
      }
    }
    shuffledCardValues = new List.from(cardValues)..shuffle();
  });
  group('streaming', () {
    test('scratch',(){
      new Stream.fromIterable(shuffledCardValues)
      .map(toCard)
      .listen(print);
//      var result = 'ah'.splitMapJoin('',
//              onMatch:    (m) => ' of ',
//              onNonMatch: (n) => n); // *shoots*
//      print(result);
    });
    
    solo_test('toCard function',(){
      List<String> cardsToTest = ['44','as', '33'];
      new Stream.fromIterable(cardsToTest)
            .map(toCard)
            .listen(expectAsync(print,count:1))//1 should work
            .onError(expectAsync((error)
                => print(error),count:2));//2 should fail
    });
    
    
    
    
    
    
    
    skip_test('fill card pile', () {
      Pile pile = new Pile(name: 'Base');
      var stream = new Stream.fromIterable(shuffledCards); // create the stream
      stream.forEach(pile.add).then((val) => print('''
deck ${pile.name} 
has ${pile.cards.length} cards 
which are 
${pile.cards}
'''));
    });
    skip_test('fill card pile and deal', () {
      Pile pile = new Pile(name: 'Base');
      deal(deck){
        print('''there are now ${deck.cards.length} cards
...dealing''');
        Stream dealingStream = new Stream.fromIterable(deck);
        //dealingStream.
      }
      var stream = new Stream.fromIterable(shuffledCardValues)
      //.expand(convertToValues)
      .asyncExpand(convertToStream)
      .map(convertToCard)
      .listen(print);
      //.forEach(print).then((_)=>null);
    });
    skip_test('list of cards traditional', () {
      var stream = new Stream.fromIterable(shuffledCards); // create the stream
      // subscribe to the streams events
      stream.listen((value) {
        print("Received: $value"); // onData handler
      });
    });
    skip_test('list of cards traditional', () {
      var deck = new Stream.fromIterable(shuffledCards); // create the stream
      var sample = new Property.fromStream(deck);
      sample.listen(print);
      //sample.when((value) => value == '2s');
      // subscribe to the streams events
//      List<Pile> piles = [new Pile(true)];
//      var sub;
//
//      sub = stream.listen((nextCard){
//        for(var pile in piles){
//          if(pile.canAccept){
//            print('adding card $nextCard');
//            pile.add(nextCard);
//            break;
//          }else if(piles.length < 8){
//
//          }
//        }
//      });
    });
    skip_test('test merge', () {
      var xs = new Stream.fromIterable(suits);
      var ys = new Stream.fromIterable(ranks);
      var zs = StreamExt.merge(xs, ys);
      var ws = new Stream.fromIterable(['#', '#', '#', '#', '#', '#', '#']);
      StreamExt.merge(zs, ws).listen(print);
    });
    skip_test('list of cards from streams', () {
      //addCard() => [];
      var cardsDealt = [];
      var cardStream = new Stream.fromIterable(cards);// create the stream
      var countCards = new Property.fromStream(cardStream);
      //var cardsDealt = new List();
      var count = countCards.scan([], (before, next) => before..add(next));
      //var cardsDealtStream = new Stream.fromIterable(cardsDealt);
      //ardsDealtStream.listen(print);
      count.listen(print);
      //suitStream.listen((i)=>print(i));
      //var es = new EventStream(suitStream);
      //var flattened = es.flatMap((t) => t);
      //flattened.asStream().listen(print);
//      var rankStream = StreamExt.repeat(new Stream.fromIterable(ranks), repeatCount:suits.length); // create the stream
//      // subscribe to the streams events
//      //print(suitStream.toList());
//      var combined  = StreamExt.merge(rankStream,suitStream);
//      combined.listen(print);
    });
  });
}

Card toCard(String currentCard) {
  return new Card.fromString(currentCard);
//  return new Stream.fromIterable(currentCard.split(''))
//  .where((cardValue) => suits.contains(cardValue) || ranks.contains(cardValue))
//  .reduce((first,second) => new Card(first,second));
}
toggle(reactable) {
  //return true;
}

class Card {
  String shortString;
  String rank;
  String suit;
  Card.fromString(this.shortString){
    List values = shortString.split('');
    if(values.length == 2 && ranks.contains(values[0]) && suits.contains(values[1])){
      rank = values[0];
      suit = values[1];
    }else{
      throw 'Unable to create card from this string value :: $shortString';
    }
  }
  Card(this.rank, this.suit);
  String toString() {
    return '$rank of $suit';
  }
}

class Pile {
  List cards;
  bool canAccept;
  String name;
  Pile({this.canAccept: true, this.name}) {
    cards = [];
  }
  add(Card card) {
    cards.add(card);
  }
}


void fillCardPile(dynamic element, Pile p) {

}


convertToCard(List values) {
  Card result = new Card(values[0],values[1]);
  return result;
}


Iterable convertToValues(String value) {
  List result = value.split('');
  return result;
}


Stream convertToStream(String event) {
  //return new Stream.fromIterable(event.)
}


bool valueIsSuit(dynamic event) {
  return suits.contains(event);
}


bool valueIsRank(dynamic event) {
  return ranks.contains(event);
}


