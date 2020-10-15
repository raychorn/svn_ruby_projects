package com.bigfix.extensions.controls {
  import flash.events.Event;
  import flash.utils.Dictionary;
	import mx.collections.ArrayCollection;
  import mx.collections.ICollectionView;
  import mx.collections.IViewCursor;
	import mx.controls.Tree;
	import com.bigfix.extensions.controls.treeClasses.CheckTreeRenderer;
	import mx.core.ClassFactory;

  [Event(name='change', type='flash.events.Event')]

	public class CheckTree extends mx.controls.Tree {
	  private var _itemState:Dictionary;
	  private var _checked:ArrayCollection;
	  
	  static public var STATE_SCHRODINGER:String = "schrodinger";
    static public var STATE_CHECKED:String = "checked";
    static public var STATE_UNCHECKED:String = "unchecked";
	  
	  public function CheckTree()
	  {
	    super();
	    itemRenderer = new ClassFactory(CheckTreeRenderer);
	    _itemState = new Dictionary();
	    _checked = new ArrayCollection();
	  }
	  
	  public function getItemState(item:*):String
	  {
	    return _itemState[item] || 'unchecked';
	  }
	  
	  private function _setItemState(item:*, state:String):void
	  {
	    if (state == 'checked' && _itemState[item] != 'checked')
	      _checked.addItem(item);
	    else if (state != 'checked' && _itemState[item] == 'checked')
	      _checked.removeItemAt(_checked.getItemIndex(item));
	    
  	  _itemState[item] = state;
	  }
	  
	  public function setItemState(item:*, state:String):void
	  {
	    var parent:* = getParentItem(item);
	    
	    _setItemState(item, state);
	    toggleChildren(item, state);
	    toggleParents(parent, getState(parent));
	    invalidateList(); // XXX: Hack to make the display refresh.
	    
	    dispatchEvent(new Event(Event.CHANGE));
	  }
	  
	  public function get checkedItems():ArrayCollection
	  {
	    return _checked;
	  }
	  
	  public function set checkedItems(ary:ArrayCollection):void
	  {
	    _checked = ary;
	    _itemState = new Dictionary();
	    
	    for each (var item:* in _checked.source) {
	      var parent:* = getParentItem(item);
	      
	      _itemState[item] = 'checked';
	      //toggleParents(parent, getState(parent));
	      //toggleChildren(item, 'checked');
	    }
	    
	    // HACK HACK HACK
	    // This ensures that the display is consistent.
      var cursor:IViewCursor = dataProvider.createCursor();
      while (!cursor.afterLast) {
        item = cursor.current;
        expandItem(item, false);
        _setItemState(item, getState(item));
        cursor.moveNext();
      }
	    invalidateList();
	  }
	  
	  private function toggleParents(item:Object, state:String):void
    {
      if (item != null) {
        var parent:* = getParentItem(item);
        
        _setItemState(item, state);
        toggleParents(parent, getState(parent));
      }
    }
    
    private function toggleChildren(item:Object, state:String):void
    {
      if (item != null) {
        _setItemState(item, state);
                
        if (dataDescriptor.hasChildren(item))
        {
          var children:ICollectionView = dataDescriptor.getChildren(item);
          var cursor:IViewCursor = children.createCursor();
          while (!cursor.afterLast) {
            toggleChildren(cursor.current, state);
            cursor.moveNext();
          }
        }
      }
    }
    
    // XXX: Needs better name.
    private function getState(parent:Object):String
    {
      var noChecks:int = 0;
      var noCats:int = 0;
      var noUnChecks:int = 0;
      
      if (parent != null) {
        var cursor:IViewCursor = dataDescriptor.getChildren(parent).createCursor();
        
        while (!cursor.afterLast) {
          if (getItemState(cursor.current) == STATE_CHECKED)
            noChecks++;
          else if (getItemState(cursor.current) == STATE_UNCHECKED)
            noUnChecks++
          else
            noCats++;

          cursor.moveNext();
        }
      }
      
      if ((noChecks > 0 && noUnChecks > 0) || (noCats > 0))
        return STATE_SCHRODINGER;
      else if (noChecks > 0)
        return STATE_CHECKED;
      else
        return STATE_UNCHECKED;
    }
  }
}
