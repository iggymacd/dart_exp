import 'package:polymer/polymer.dart';
import 'dart:convert';
import 'dart:html';

/**
 * A Polymer playing card element.
 */
@CustomTag('playing-card')
class PlayingCard extends PolymerElement {
  @published num size;
  @published String rank = 'a';
  @published String suit = 'h';
  @published bool show = false;
  @published num left = 0;
  @published num top = 0;
  List<String> suitValues;
  Map suitMap;
  Map suitClassMap;
  Map rankMap;
//  @published Function handleCardTapped = (Event event, var detail, Node target){
//    print('in card tapped handler');
//  };
  var conv;
  
  String get rankView => rankMap[rank];
  String get suitClass => suitClassMap[suit];
  String get down => show ? '' : 'down';
  PlayingCard.created() : super.created() {
    //conv = new HtmlEscape();
    //suitValues = ["♦","♥","♣","♠"];
    //rank = '8';
    suitClassMap = {'d':"diamonds",'h':"hearts",'c':"clubs",'s':"spades",
                    'diamonds':"diamonds",'hearts':"hearts",'clubs':"clubs",
                    'spades':"spades"};
    //suitMap = {'d':"♦",'h':"♥",'c':"♣",'s':"♠",'diamonds':"♦",'hearts':"♥",
               //'clubs':"♣",'spades':"♠"};
    rankMap = {'a':'A','2':'2','3':'3','4':'4','5':'5','6':'6','7':'7','8':'8',
               '9':'9','t':'10','ten':'10','j':'J','q':'Q','k':'K'};
    //rank = "A";
  }
  
  void handleCardTapped(Event event, var detail, Node target){
    print('in card tapped handler');
    //flip();
    asyncFire('cardclicked');
  }
  void handleDoubleClick(Event event, var detail, Node target){
    print('in double click handler');
    turn();
    //asyncFire('dblclicked');
  }

  void turn() {
    print("in tap handler");
    Element card = this.shadowRoot.querySelector('.card');
    //Element card = this.
    card.classes.toggle('down');
  }
}

