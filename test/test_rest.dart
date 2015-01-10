import 'dart:async';
//import 'dart:html';
import 'dart:convert';

import 'package:scheduled_test/scheduled_test.dart';
//import 'package:unittest/unittest.dart';
import 'package:observe/observe.dart';
import 'package:event_bus/event_bus.dart';
import '../packages/logging/logging.dart';

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
const List rankFilter = const ['2', '3', '4', '5'];
final EventBus dispatcher = new EventBus();
final Logger logger = new Logger('app model');
/** Key for state information ([value] = 750). */
const Level STATE = const Level('STATE',850);

filterForGame(card) {
  return !rankFilter.contains(card);
}
printLogRecord(LogRecord r) {
  print('${r.level.name}|${r.loggerName}|${r.message}|sequence is ${r.sequenceNumber} and occurred at ${r.time}');
}
void main() {

  group('app -',(){
//    var sw = new Stopwatch()..start();
    AppModel appModel = new AppModel('tarabish',logger:logger);
    appModel.observe(dispatcher);
    List staticValues = 
        ['6s','ts','6d','kd','9h','jh','7s','9c','8d','8s','qh','jc','as','kc','ks','ah','8c','th','7c','8h','9d','6h','qc','7h','7d','ad','tc','qd','6c','js','9s','ac','kh','qs','td','jd'];
    List cardValues;
    //List shuffledCardValues;
    cardValues = [];
    //traditional approach
    for (var rank in ranks.where(filterForGame)) {
      for (var suit in suits) {
        cardValues.add('$rank$suit');
      }
    }
    shuffledCardValues()=>new List.from(cardValues)..shuffle();
    GameRecord gr = new GameRecord();
    EventBus bus = new EventBus();
    SampleGameModel game = new SampleGameModel(bus);
    print(game.deck.isEmpty);
    setUp(() {
    });
    skip_test('game simulation',(){
      var gameTableShouldBeSetup = expectAsync((){
        expect(appModel.table.foundation, isNotNull);
        expect(appModel.table.playedCards, isNotNull);
        expect(appModel.table.northHand, isNotNull);
        expect(appModel.table.eastHand, isNotNull);
        expect(appModel.table.southHand, isNotNull);
        expect(appModel.table.westHand, isNotNull);
        expect(appModel.table.currentState,equals(State.NEW));
      });
      appModel.table.whenSetupMessageIsReceived()
        .then((_)=>gameTableShouldBeSetup());
      simulateGame();
    });
    skip_test('scratch',(){
      Function f = ()=>'I am a function';
      EventBus bus = new EventBus();
      SampleEvent event = new SampleEvent();
      Sample mySample = new Sample();
      Symbol mySymbol = new Symbol('me');
      print(event.f);
      mySymbol.toString();
      //mySample.
      mySample.observe(bus.on(SampleEvent));
      mySample.changes.listen(print);
      logger.onRecord
          .where((LogRecord record)=>record.level == STATE)
          //.toList()
          .listen((_){
            bus.fire(event..message = _.message);
            bus.fire(event..f = (p)=>'$p func here');
            //Function.
          });
      logger.log(STATE, 'hello');
      logger.log(STATE, 'there');
      //mylist.
//          .firstWhere((record)=>record.message == 'setup table')
//          .then((_)=>init());

    });
    test('fill deck',(){
      StreamSubscription sub;
      gr.action = Action.FILL_DECK;
      gr.deck = shuffledCardValues();
      var expectDeckIsFull =
        expectAsync((){
          expect(game.deck.length,equals(36));
          print(game.deck);
          sub.cancel();
        });      
      sub = logger.onRecord
      .where((l)=>l.level==STATE && l.message == 'finished filling deck')
      .listen((_)=>expectDeckIsFull());
      bus.fire(gr);
    });
    skip_test('shuffle deck',(){
      StreamSubscription sub;
      gr.action = Action.REPLACE_DECK;
      gr.deck = shuffledCardValues();
      var expectDeckIsShuffled =
        expectAsync((){
          expect(game.deck.length,equals(36));
          print(game.deck);
          sub.cancel();
        });      
      sub = logger.onRecord
      .where((l)=>l.level==STATE && l.message == 'finished shuffling deck')
      .listen((_)=>expectDeckIsShuffled());
      bus.fire(gr);
    });
    test('set dealer',(){
      StreamSubscription sub;
      gr.action = Action.SET_DEALER;
      gr.position = 'north';
      var expectDealerIsNorth =
        expectAsync((){
        expect(game.dealer,equals('north'));
        print(game.deck);
        sub.cancel();
      });      
      sub = logger.onRecord
      .where((l)=>l.level==STATE && l.message == 'finished setting dealer')
      //.first
      .listen((_)=>expectDealerIsNorth());
      bus.fire(gr);
    });
    test('shuffle deck static',(){
      StreamSubscription sub;
      gr.action = Action.REPLACE_DECK;
      gr.deck = staticValues;
      var expectDeckIsShuffled =
        expectAsync((){
          expect(game.deck.length,equals(36));
          print(game.deck);
          sub.cancel();
        });      
      sub = logger.onRecord
      .where((l)=>l.level==STATE && l.message == 'finished shuffling deck')
      .listen((_)=>expectDeckIsShuffled());
      bus.fire(gr);
    });
    test('deal bidding cards',(){
      StreamSubscription sub;
      //gr.action = Action.DEAL_BIDDING_CARDS;
      //gr.data = JSON.encode(staticValues);
      var expectBiddingCardsAreDealt =
        expectAsync((){
        expect(game.deck.length,equals(12));
        expect(game.northHand.length,equals(6));
        expect(game.eastHand.length,equals(6));
        expect(game.westHand.length,equals(6));
          expect(game.southHand.length,equals(6));
          print(game.eastHand);
          print(game.southHand);
          print(game.westHand);
          print(game.northHand);
          sub.cancel();
        });      
      sub = logger.onRecord
      .where((l)=>l.level==STATE && l.message == 'finished dealing bidding cards')
      .listen((_)=>expectBiddingCardsAreDealt());
      List positions = ['east','south','west','north'];
      var biddingCards = staticValues.take(24).toList();
      var position = (positions.indexOf('north') + 1)%4;
      for(int i = 0;i < biddingCards.length;i++){
        gr = new GameRecord();
        gr.action = Action.DEAL_BIDDING_CARDS;
        if(i>0 && i%3 == 0){
          position = (position + 1)%4;
        }
        gr.card = biddingCards[i];
        gr.position = positions[position];
        //gr.data = JSON.encode({'card':'${biddingCards[i]}','destination':positions[position]});
        bus.fire(gr);
      }
    });//
    test('player bidding',(){
      StreamSubscription sub;
      var expectBiddingIsComplete =
        expectAsync((){
        expect(game.trump,equals('hearts'));
          print(game.deck);
          sub.cancel();
        });      
      sub = logger.onRecord
      .where((l)=>l.level==STATE && l.message == 'finished player bidding')
      .listen((_)=>expectBiddingIsComplete());
      List positions = ['east','south','west','north'];
      List bids = ['hearts','spades','diamonds','clubs'];
//      var biddingCards = staticValues.skip(24);
      var position = (positions.indexOf('north') + 1)%4;
      for(int i = 0;i < positions.length;i++){
        gr = new GameRecord();
        gr.action = Action.PLAYER_BID;
        if(position==1){
          gr.bid = 'hearts';
          gr.position = positions[position];
          //gr.data = JSON.encode({'bid':'hearts','position':positions[position]});
          bus.fire(gr);
          break;
        }
        gr.bid = 'pass';
        gr.position = positions[position];
        //gr.data = JSON.encode({'bid':'pass','position':positions[position]});        
        bus.fire(gr);
        position = (position + 1)%4;
      }
    });
    test('deal kitty cards',(){
      StreamSubscription sub;
      var expectKittyCardsAreDealt =
        expectAsync((){
        expect(game.deck.length,equals(0));
        expect(game.northHand.length,equals(9));
        expect(game.eastHand.length,equals(9));
        expect(game.westHand.length,equals(9));
          expect(game.southHand.length,equals(9));
          print(game.eastHand);
          print(game.southHand);
          print(game.westHand);
          print(game.northHand);
          sub.cancel();
        });      
      sub = logger.onRecord
      .where((l)=>l.level==STATE && l.message == 'finished dealing kitty cards')
      .listen((_)=>expectKittyCardsAreDealt());
      List positions = ['east','south','west','north'];
      var kittyCards = staticValues.skip(24).toList();
      var position = (positions.indexOf('north') + 1)%4;
      for(int i = 0;i < kittyCards.length;i++){
        gr = new GameRecord();
        gr.action = Action.DEAL_KITTY_CARDS;
        if(i>0 && i%3 == 0){
          position = (position + 1)%4;
        }
        gr.card = kittyCards[i];
        gr.position = positions[position];
        bus.fire(gr);
      }
    });//
    test('play round of cards',(){
      //Timer t = new Timer(const Duration(seconds: 3),()=>null);
      var sw = new Stopwatch()..start();
      StreamSubscription sub;
      StreamSubscription sub2;
      var expectAllCardsArePlayed =
        expectAsync((){
        print(game.currentTrick);
        expect(game.deck.length,equals(0));
        expect(game.northHand.length,equals(0));
        expect(game.eastHand.length,equals(0));
        expect(game.westHand.length,equals(0));
          expect(game.southHand.length,equals(0));
          print('winninghands are ${game.winningHands}');
          sub.cancel();
          sw.stop();
              print('test took ${sw.elapsedMilliseconds} ms');
        });      
      var expectTrickWasWon =
        expectAsync((){
//        print(game.currentTrick);
//        expect(game.deck.length,equals(0));
//        expect(game.northHand.length,equals(0));
//        expect(game.eastHand.length,equals(0));
//        expect(game.westHand.length,equals(0));
//          expect(game.southHand.length,equals(0));
          //sub2.cancel();
        },count:9);      
      sub = logger.onRecord
      .where((l)=>l.level==STATE && l.message == 'finished playing cards')
      .listen((_)=>expectAllCardsArePlayed());
      sub2 = logger.onRecord
      .where((l)=>l.level==STATE && l.message == 'current trick won')
      .listen((_)=>expectTrickWasWon());
      Map cardsToPlay = {
                   '1':{'east':'6s','south':'js','west':'7s','north':'8s','wonBy':'south'},
                   '2':{'south':'jh','west':'8h','north':'qh','east':'6d','wonBy':'south'},
                   '3':{'south':'9h','west':'kh','north':'6h','east':'7d','wonBy':'south'},
                   '4':{'south':'ah','west':'8d','north':'7h','east':'ks','wonBy':'south'},
                   '5':{'south':'6c','west':'ac','north':'jc','east':'tc','wonBy':'west'},
                   '6':{'west':'9d','north':'jd','east':'ad','south':'qd','wonBy':'east'},
                   '7':{'east':'as','south':'th','west':'9s','north':'qs','wonBy':'south'},
                   '8':{'south':'kd','west':'7c','north':'td','east':'ts','wonBy':'north'},
                   '9':{'north':'qc','east':'kc','south':'8c','west':'9c','wonBy':'east'},
      };
      for(var trick in cardsToPlay.keys){
        for(var position in cardsToPlay[trick].keys.where((key)=>key != 'wonBy')){
//          new Future.delayed(const Duration(milliseconds: 10), () {
//            bus.fire(new GameRecord.playCard(card:cardsToPlay[trick][position],position:position));
//          });
          //new Future.delayed(new Duration(seconds: 1), () => bus.fire(new GameRecord.playCard(card:cardsToPlay[trick][position],position:position)));
          bus.fire(new GameRecord.playCard(card:cardsToPlay[trick][position],position:position));
//          new Timer.periodic(new Duration(seconds:1), (timer) {
//            bus.fire(new GameRecord.playCard(card:cardsToPlay[trick][position],position:position));
//            timer.cancel();
//            });
        }
//        new Timer.periodic(new Duration(seconds:4), (timer) {
//          bus.fire(new GameRecord.trickWon(position:cardsToPlay[trick]['wonBy']));
//                    timer.cancel();
//                    });
        bus.fire(new GameRecord.trickWon(position:cardsToPlay[trick]['wonBy']));
      }      
    });
    
  });
}


class SampleGameModel{
  List<Card> deck;
  List<Card> northHand;
  List<Card> eastHand;
  List<Card> southHand;
  List<Card> westHand;
  Map<String,List<Card>> hands;
  List<Card> northWinningTricks;
  List<Card> eastWinningTricks;
  List<Card> southWinningTricks;
  List<Card> westWinningTricks;
  List<Card> currentTrick;
  Map<String,List<Card>> winningHands;
  EventBus bus;
  String dealer;
  State state;
  String trump;
  final DateTime time;
  final int sequenceNumber;
  static int _nextNumber = 0;
  
  SampleGameModel(this.bus)
  : time = new DateTime.now(),
        sequenceNumber = SampleGameModel._nextNumber++
  {
    deck = new List<Card>();
    northHand = new List<Card>();
    eastHand = new List<Card>();
    southHand = new List<Card>();
    westHand = new List<Card>();
    hands = {};
    hands['north'] = northHand;
    hands['east'] = eastHand;
    hands['south'] = southHand;
    hands['west'] = westHand;
    northWinningTricks = new List<Card>();
    eastWinningTricks = new List<Card>();
    southWinningTricks = new List<Card>();
    westWinningTricks = new List<Card>();
    currentTrick = new List<Card>();
    winningHands = {};
    winningHands['north'] = northWinningTricks;
    winningHands['east'] = eastWinningTricks;
    winningHands['south'] = southWinningTricks;
    winningHands['west'] = westWinningTricks;
    state = State.NEW;
    setupListeners();
  }
  
  void setupListeners() {
    
    Future.forEach([
      listenForFillDeckEvents,
      //listenForShuffleDeckEvents,
      listenForSetDealerEvents,
      listenForReplaceDeckEvents,
      listenForDealBiddingCardEvents,
      listenForPlayerBidEvents,
      listenForDealKittyCardEvents,
      listenForPlayCardEvents
    ],
      (f)=>f()//call each function
    );
    listenForTrickWonByPlayerEvents();
    
  }
  void releaseListeners(){//not sure if this is useful
    //bus.destroy();
  }
  Future listenForTrickWonByPlayerEvents(){
    return bus.on(GameRecord)
    .where((r)=>r.action == Action.TRICK_WON)
    //.map(toCards)
    .take(9)//we are expecting 9 tricks per round
    .listen(updateTricks)
    .asFuture()
    .whenComplete(()=>logger.log(STATE, 'all tricks played'));
    //.then((_)=>logger.log(STATE, 'all tricks played'));
  }

  Future listenForMessageEvents(){
    return bus.on(GameRecord)
    .where((r)=>r.action == Action.MESSAGE)
    .listen(postMessage)
    .asFuture()
    .whenComplete(()=>logger.log(STATE, 'no longer listening to messages'));
  }

  Future listenForReplaceDeckEvents() {
    return bus.on(GameRecord)
    .where((r)=>r.action == Action.REPLACE_DECK)
    .map(toCards)
    .first
    .then(replaceDeck);
    //.listen(setShuffled);
  }

  Future listenForSetDealerEvents() {
    return bus.on(GameRecord)
    .where((r)=>r.action == Action.SET_DEALER)
    //.map((r)=>r.data)
    .first
    .then(setDealer);
    //.listen(setDealer);
  }
  
   logState(result) {
  }

  Future listenForFillDeckEvents() {
    Stream stream = 
    bus.on(GameRecord)
    .where((r)=>r.action == Action.FILL_DECK)
    .map(toCards);
    return stream.first
        .then((cards){
      deck.replaceRange(0, deck.length, cards);
      logger.log(STATE, 'finished filling deck');
    });
  }
  
  Future listenForPlayCardEvents() {
    Stream cardPlayedEvents = bus.on(GameRecord)
    .where((r)=>r.action == Action.PLAY_CARD)
    .take(36);//expect 9 cards from 4 players
    StreamSubscription sub;
    sub = cardPlayedEvents.listen((record){
      if(currentTrick.length == 4){
        sub.pause(logger.onRecord
            .where((l)=>l.level==STATE && l.message == 'current trick won')
            .first);
        playCard(record);
      }else{
        playCard(record);
      }
    });
        return sub.asFuture()
            .whenComplete(()=>logger.log(STATE, 'finished playing cards'));
       // .then((_)=>logger.log(STATE, 'finished playing cards'));
  }
  
  Future listenForDealKittyCardEvents() {
    return bus.on(GameRecord)
    .where((r)=>r.action == Action.DEAL_KITTY_CARDS)
    .take(12)
    .listen(dealBiddingCard)//,
        .asFuture()
        .then((_)=>logger.log(STATE, 'finished dealing kitty cards'));
  }

  Future listenForDealBiddingCardEvents() {
    return bus.on(GameRecord)
    .where((r)=>r.action == Action.DEAL_BIDDING_CARDS)
    .take(24)
    .listen(dealBiddingCard)//,
        //onDone:()=>logger.log(STATE, 'finished dealing bidding cards'))
        .asFuture()
        .then((_)=>logger.log(STATE, 'finished dealing bidding cards'));
  }

  Future listenForPlayerBidEvents() {
    //StreamSubscription playerBidSubscription;
    return bus.on(GameRecord)
    .where((r)=>r.action == Action.PLAYER_BID)
    //.map(toMap)
    .firstWhere((data)=>data.bid != 'pass')
    .then((data){
        trump = data.bid;
        logger.log(STATE, 'finished player bidding');
    });
  }
  
  replaceDeck(List<Card> cardValues) {
    print('in setShuffled...');
    deck.replaceRange(0, deck.length, cardValues);
    logger.log(STATE, 'finished shuffling deck');
  }
  
  handleFillDeckEvent(List<Card> cardValues) {
    deck.replaceRange(0, deck.length, cardValues);
    logger.log(STATE, 'finished filling deck');
  }
  
  setDealer(GameRecord record) {
    dealer = record.position;
    logger.log(STATE, 'finished setting dealer');
  }
  
  Card cardFromJson(GameRecord record) {
    Map decoded = JSON.decode(record.toJson);
    return toCard(decoded['card']);
  }
  
  
  void playCard(GameRecord record) {
    Card cardToPlay = toCard(record.card);
    String sourceHand = record.position;
    List targetHand = currentTrick;
    if(hands[sourceHand].remove(cardToPlay)){
      targetHand.add(cardToPlay);
    }else{
      print('${hands[sourceHand]} does not contain ${cardToPlay}');
    }
    
    print('$cardToPlay was played by $sourceHand');
  }
  
  void dealBiddingCard(GameRecord record) {
    //print('in dealBiddingCard');
    Card cardToDeal = toCard(record.card);//cardFromJson(record);
    deck.removeAt(0);
    String targetHand = record.position;
    hands[targetHand].add(cardToDeal);
  }
  
  Map toMap(GameRecord record) {
    Map result = JSON.decode(record.toJson);
    print('in toMap $result');
    return result;
  }
  
  void updateTricks(GameRecord record) {
    //clear currentTrick list and fill position wonTrick list
    String postionThatWonTrick = record.position;
    //String
    List<Card> target = this.winningHands[postionThatWonTrick];
    target.addAll(this.currentTrick);
    currentTrick.clear();
    logger.log(STATE, 'current trick won');
  }
  
  void postMessage(GameRecord record) {
    
  }
}
class GameRecord{
  final DateTime time;
  final int sequenceNumber;
  static int _nextNumber = 0;
  String get toJson => JSON.encode({
    'card':card,
    'postion':position,
    'deck':deck
    });
  
  Action action;
  String card;
  String position;
  String bid;
  String message;
  List<String> deck;
  GameRecord():
    time = new DateTime.now(),
    sequenceNumber = GameRecord._nextNumber;
  GameRecord.playCard({this.card,this.position}):
    action = Action.PLAY_CARD,
    time = new DateTime.now(),
    sequenceNumber = GameRecord._nextNumber;
  GameRecord.trickWon({this.card,this.position}):
    action = Action.TRICK_WON,
    time = new DateTime.now(),
    sequenceNumber = GameRecord._nextNumber;
  GameRecord.postMessage({this.message,this.position}):
    action = Action.MESSAGE,
    time = new DateTime.now(),
    sequenceNumber = GameRecord._nextNumber;
  
}
class SampleEvent{
  Sample s;
  Symbol symbol;
  String message;
  Function f;
  SampleEvent({this.symbol:#prop});
  myFunc(){
    
  }
}

simulateGame() {
  logger.log(STATE,'setup table');
  logger.log(STATE,'add deck');
  logger.log(STATE,'shuffle deck');
  logger.log(STATE,'choose dealer north');
  logger.log(STATE,'north shuffles deck');
  logger.log(STATE,'north deals bidding cards');
  logger.log(STATE,'east bids pass');
  logger.log(STATE,'south bids pass');
  logger.log(STATE,'west bids pass');
  logger.log(STATE,'north bids ?');
  logger.log(STATE,'north deals remaining cards');
  logger.log(STATE,'east plays card ?');
  logger.log(STATE,'south plays card ?');
  logger.log(STATE,'west plays card');
  logger.log(STATE,'north plays card');
  logger.log(STATE,'east wins trick');
  logger.log(STATE,'east plays card ?');
  logger.log(STATE,'south plays card ?');
  logger.log(STATE,'west plays card');
  logger.log(STATE,'north plays card');
  logger.log(STATE,'east wins trick');
  logger.log(STATE,'east plays card ?');
  logger.log(STATE,'south plays card ?');
  logger.log(STATE,'west plays card');
  logger.log(STATE,'north plays card');
  logger.log(STATE,'east wins trick');
  logger.log(STATE,'east plays card ?');
  logger.log(STATE,'south plays card ?');
  logger.log(STATE,'west plays card');
  logger.log(STATE,'north plays card');
  logger.log(STATE,'east wins trick');
  logger.log(STATE,'east plays card ?');
  logger.log(STATE,'south plays card ?');
  logger.log(STATE,'west plays card');
  logger.log(STATE,'north plays card');
  logger.log(STATE,'east wins trick');
  logger.log(STATE,'east plays card ?');
  logger.log(STATE,'south plays card ?');
  logger.log(STATE,'west plays card');
  logger.log(STATE,'north plays card');
  logger.log(STATE,'east wins trick');
  logger.log(STATE,'east plays card ?');
  logger.log(STATE,'south plays card ?');
  logger.log(STATE,'west plays card');
  logger.log(STATE,'north plays card');
  logger.log(STATE,'east wins trick');
  logger.log(STATE,'east plays card ?');
  logger.log(STATE,'south plays card ?');
  logger.log(STATE,'west plays card');
  logger.log(STATE,'north plays card');
  logger.log(STATE,'east wins trick');
  logger.log(STATE,'east plays card ?');
  logger.log(STATE,'south plays card ?');
  logger.log(STATE,'west plays card');
  logger.log(STATE,'north plays card');
  logger.log(STATE,'east wins trick');
  logger.log(STATE,'display round result');
  logger.log(STATE,'display game totals');
}

Future simulateNewGameRequest() {
  Message newGameMessage = new Message.info(action:Action.NEW_GAME);
  dispatcher.fire(newGameMessage);
  return new Future.value();
}

Future simulatePopulatingShuffledDeck() {
  List cardValues;
  List shuffledCardValues;
  cardValues = [];
  //traditional approach
  for (var rank in ranks.where(filterForGame)) {
    for (var suit in suits) {
      cardValues.add('$rank$suit');
    }
  }
  shuffledCardValues = new List.from(cardValues)..shuffle();
  return new Stream.fromIterable(shuffledCardValues)
  .map((cardValue) => new Message
    .content(data:cardValue,action:Action.ADD_CARD))
  .forEach(dispatcher.fire);
}

expectDeckToBePopulated(AppModel appModel) async{
  expect(appModel.deckOfCards.length,equals(36));
  await whenDeckIsFull(appModel);
}

Future whenDeckIsFull(AppModel appModel) async{
  return appModel.deckOfCards.listChanges
                .where((_)=>_.last.index == 35)//when deck is dealt
                .first;
}
Future whenGameIsReady(AppModel appModel){
  return appModel.logger.onRecord
      .where((logRecord)=>logRecord.message == 'Game is ready')
      .first;
}
Future whenGameIsNew(AppModel appModel){
  return appModel.changes
      .asyncExpand((data)=>new Stream.fromIterable(data))
      .first;
}

playRoundOne(gameStore) async{
  await expectAllPositionsHaveOneLess(gameStore);
  await roundOneComplete(gameStore);
}

Future roundOneComplete(AppModel gameStore){
  print('in roundOneComplete');
  return gameStore.tablePositions['play'].cards.listChanges
                .where((_)=>_.last.index == 3)//when deck is dealt
                .first;
}

void expectAllPositionsHaveOneLess(gameStore) {
  print('Play stack is ${gameStore.tablePositions['play'].cards.length}');
  expect(gameStore.tablePositions['play'].cards.length == 3,isTrue);
}
dealCards(gameStore) async{
  expectAllPositionsDealt(gameStore);
  await deckIsDealt(gameStore);
  await whenDeckIsFull(gameStore);
}

expectAllPositionsDealt(AppModel gameStore) {
  return new Stream.fromIterable(gameStore.tablePositions.keys)
  .take(4)
  .where((k)=>['northHand',
               'eastHand',
               'southHand',
               'westHand'].contains(k))
  
  .forEach((_){
    print('$_ length is ${gameStore.tablePositions[_].cards.length}');
    expect(gameStore.tablePositions[_].cards.length == 9,isTrue);
  });
}

Future deckIsDealt(AppModel gameStore) {
  return gameStore.deckOfCards.listChanges
  .where((_)=>_.last.index == 0)//when deck is full
  .first;
  //return new Future.value(gameStore);
}

Future simulateDealCards(){
  print('in simulateDealCards');
  var positions = new Stream.fromIterable([//simulate dealing to each position
    '0',
        '0',
        '0',
        '1',
        '1',
        '1',
        '2',
        '2',
        '2',
        '3',
        '3',
        '3',
        '0',
        '0',
        '0',
        '1',
        '1',
        '1',
        '2',
        '2',
        '2',
        '3',
        '3',
        '3',
        '0',
        '0',
        '0',
        '1',
        '1',
        '1',
        '2',
        '2',
        '2',
        '3',
        '3',
        '3']);
  return positions
      .map(convertToMessage)
      .forEach(dispatcher.fire);
}

 convertToMessage(position) => new Message.content(data:position,action:Action.DEAL_CARD);

class AppModel extends Observable{
  @observable GameModel currentGame;
  TableModel table;
  EventBus dispatcher;
  State state;
  Map<String, CardStack> tablePositions;
  ObservableList deckOfCards;
  Logger logger;
  bool cardsDealt;
  String name;
  Stream onMessage;
  AppModel(this.name,{this.logger}){
    table = new TableModel(logger:logger);
    state = State.NEW;
    cardsDealt = false;
    //currentGame = new GameModel();
    //onMessage = dispatcher.on(Message);
    //logger = new Logger(name);
    deckOfCards = new ObservableList();
    tablePositions = new Map();
      [   'northHand',
          'eastHand',
          'southHand',
          'westHand',
          'play',
          'northWon',
          'eastWon',
          'southWon',
          'westWon'].forEach((positionName) {
        tablePositions[positionName] = new CardStack(name: positionName);
      });
  }
  Future onDealCardsMessage() => dispatcher.on(String)
      //.where((message) => message.action == 'deal')
        .takeWhile(deckIsNotEmpty)//deal all cards in deck
        .where((position) =>['0','1','2','3'].contains(position))
        .map(toTablePosition)//returns a stream of table positions
        .forEach(dealCardToPosition)
        .whenComplete(()=>cardsDealt = true);
  Future onPlayCardsMessage() => dispatcher.on(String)
      //.where((message) => message.action == 'deal')
      .where((_)=>cardsDealt)//deal all cards in deck
        .where((position) =>['0','1','2','3'].contains(position))
        .map(toTablePosition)//returns a stream of table positions
        .forEach(playCardFromPosition);
        //.whenComplete(() => print('here....')/**/);

  
  deckIsNotEmpty(_) => deckOfCards.isNotEmpty;
deckIsEmpty(_) => deckOfCards.isEmpty;

toTablePosition(dynamic position) {
  return {
    '0': tablePositions['westHand'],
    '1': tablePositions['northHand'],
    '2': tablePositions['eastHand'],
    '3': tablePositions['southHand']
  }[position];
}
dealCardToPosition(CardStack position) {
  position.cards.add(deckOfCards.removeLast());
  logger.info(()=>'${position.name} has :: ${position.cards.length} cards');
}
playCardFromPosition(CardStack position) {
  Card playedCard;
  tablePositions['play'].add(playedCard = position.cards.removeLast());
  logger.info(()=>'${position.name} has played :: ${playedCard}');
}

  
  void observe(EventBus dispatcher) {
    Stream s = dispatcher.on(Message);
    
    s
    .where((Message message)=>
        message.messageType == MessageType.CONTENT &&
        message.action == Action.ADD_CARD)
    .take(36)
    .map((Message message)=>message.data)
    .map(toCard)
    .forEach(deckOfCards.add);
    
    s
    .firstWhere((Message message)=>
        message.messageType == MessageType.INFO &&
        message.action == Action.NEW_GAME)
    .then((_)=>createNewGame());
  }
  
  createNewGame() {
    print('in createNewGame');
    currentGame = new GameModel();
    currentGame.state = State.NEW;
    logger.info('Game is ready');
  }
}

class TableModel {
  State currentState;
  Logger logger;
  List<Card> foundation;
  List<Card> playedCards;
  List<Card> northHand;
  List<Card> southHand;
  List<Card> eastHand;
  List<Card> westHand;
  TableModel({this.logger}){    
    
  }
  
   init() {
    print('in init');
    
    currentState = State.NEW;
    foundation = [];
    playedCards = [];
    northHand = [];
    eastHand = [];
    southHand = [];
    westHand = [];
    //return new Future.value();
  }
  
  Future whenSetupMessageIsReceived() {
    return logger.onRecord
        .where((LogRecord record)=>record.level == STATE)
        .firstWhere((record)=>record.message == 'setup table')
        .then((_)=>init());
  }
}

class GameModel extends Observable {
  @observable State state;
}

class Card {
  String shortString;
  String rank;
  String suit;
  State state;
  Card.fromString(this.shortString) {
    List values = shortString.split('');
    if (values.length == 2 &&
        ranks.contains(values[0]) &&
        suits.contains(values[1])) {
      rank = values[0];
      suit = values[1];
    } else {
      throw 'Unable to create card from this string value :: $shortString';
    }
  }
  Card(this.rank, this.suit);
  String toString() {
    return '$rank of $suit';
  }
  bool operator==(other){
    return this.rank == other.rank && this.suit == other.suit;
  }
}
class CardStack {
  ObservableList cards;
  bool canAccept;
  String name;
  CardStack({this.canAccept: true, this.name}) {
    cards = new ObservableList();
  }
  add(Card card) {
    cards.add(card);
  }
}

class Message{
  MessageType messageType;
  Action action;
  dynamic data;
  
  printLogRecord(LogRecord r) {
    print('action is ${action}|${r.level.name}|${r.loggerName}|${r.message}|sequence is ${r.sequenceNumber} and occurred at ${r.time}');
  }  
  
  Message.info({this.action}){
    messageType = MessageType.INFO;
  }
  Message.content({this.data,this.action}){
    messageType = MessageType.CONTENT;
  }
}

Card toCard(String currentCard) {
  return new Card.fromString(currentCard);
}

List<Card> toCards(GameRecord gameRecord) {
  String currentCards = gameRecord.toJson;
 List<String> cards = JSON.decode(currentCards)['deck'];
  return cards.map((card)=> new Card.fromString(card)).toList();
      //new Card.fromString(cards);
}

enum State {INITIALIZING,READY,ACTIVE,NEW,COMPLETE,IN_PROGRESS}
enum MessageType{INFO,CONTENT}
enum Action {
  DEAL_KITTY_CARDS,
  DEAL,
  ADD_CARD,
  DEAL_CARD,
  NEW_GAME,
  FILL_DECK,
  SET_DEALER,
  REPLACE_DECK,
  DEAL_BIDDING_CARDS,
  PLAYER_BID,
  PLAY_CARD,
  TRICK_WON,
  MESSAGE
  }



class Sample extends Observable{
  String  myProp = 'nothing';
  @observable String get prop => myProp;
  @observable set prop(val){
    //myProp = val;
    myProp = notifyPropertyChange(#prop, prop, val);
  }
  @observable String property;
  observe(Stream s){
    s.where((data)=>data is SampleEvent)
    .where((data)=>data.symbol == #prop)
    .listen((data)=>prop = data.message);
    s.where((data)=>(data.f != null))
    .listen((data)=>prop = data.f(prop));
  }
  
  update({prop:null,color:null}){
    
  }
}
