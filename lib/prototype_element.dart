import 'package:polymer/polymer.dart';

/**
 * A Polymer prototype-element element.
 */
@CustomTag('prototype-element')

class PrototypeElement extends PolymerElement {

  /// Constructor used to create instance of PrototypeElement.
  /// here we will call for initial model values from model store
  PrototypeElement.created() : super.created() {
  }
  /// we will start listening for changes on model stores we are interested in
  attached() {
    super.attached();
  }

  /// we will stop listening for changes on the model stores.
  detached() {
    super.detached();
  }
  /*
   * Optional lifecycle methods - uncomment if needed.
   *

  /// Called when an instance of prototype-element is inserted into the DOM.
  attached() {
    super.attached();
  }

  /// Called when an instance of prototype-element is removed from the DOM.
  detached() {
    super.detached();
  }

  /// Called when an attribute (such as  a class) of an instance of
  /// prototype-element is added, changed, or removed.
   * also - when a published property changes, you can use 
   * <propertyName>Changed(oldval,newVal){...}
  attributeChanged(String name, String oldValue, String newValue) {
  }

  /// Called when prototype-element has been fully prepared (Shadow DOM created,
  /// property observers set up, event listeners attached).
  ready() {
  }
   
  */
  
}
