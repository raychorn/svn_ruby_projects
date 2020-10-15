package com.bigfix.dss.model {
  import mx.collections.ArrayCollection;
  import mx.events.CollectionEvent;
  import mx.events.CollectionEventKind;
  import com.bigfix.dss.vo.ComputerGroupVO;
  import com.bigfix.dss.event.ComputerGroupTreeEvent;
  import flash.utils.Dictionary;
  import mx.utils.UIDUtil;
  import flash.events.EventDispatcher;
  
  public class ComputerGroupTree extends EventDispatcher {
    [Bindable]
    public var root:ComputerGroupVO;
    private var _parentMap:Dictionary;
    private var _childrenMap:Dictionary;
    private var _idMap:Array;
    private var _initialized:Boolean = false;
    
    public function ComputerGroupTree(allGroups:ArrayCollection)
    {
      var group:ComputerGroupVO;
      
      root = new ComputerGroupVO();
      root.name = 'ROOT';
      root.children = new ArrayCollection();
      
      _idMap = new Array();
      _parentMap = new Dictionary();
      _childrenMap = new Dictionary();
      
      // We need a mapping from id to group in order to construct the tree.
      _idMap[0] = root;
      for each (group in allGroups) {
        _idMap[group.id] = group;
        group.children = new ArrayCollection();
      }
      
      addTreeNode(root);
      for each (group in allGroups) {
        addTreeNode(group);
      }
      
      _initialized = true;
    }
    
    public function getByID(id:int):ComputerGroupVO
    {
      return _idMap[id];
    }
    
    public function remove(group:ComputerGroupVO):void
    {
      var parent:ComputerGroupVO = getParent(group);
      
      parent.children.removeItemAt(parent.children.getItemIndex(group));
    }
    
    public function getParent(group:ComputerGroupVO):ComputerGroupVO
    {
      var uid:String = UIDUtil.getUID(group);
      return _parentMap[uid];
    }
    
    private function addTreeNode(group:ComputerGroupVO, parent:ComputerGroupVO=null):void
    {
      // Keep a pointer from the 'children' attribute back to the
      // group itself, so we know who got updated when the
      // COLLECTION_CHANGE event is received.
      _childrenMap[UIDUtil.getUID(group.children)] = group;

      // Update the tree structure
      if (group != root) {
        if (parent == null) {
          parent = _idMap[group.parent_id];
          if (parent == null)
            parent = root;
            
          parent.children.addItem(group);
        }
        // If we were passed in a parent reference, assume that the parent's
        // children array has already been updated.

        _parentMap[UIDUtil.getUID(group)] = parent;
      }

      // Listen for changes to the group's children, so we can adjust our
      // internal state and notify our own event listeners.
      group.children.addEventListener(CollectionEvent.COLLECTION_CHANGE,
                                      this.nestedChangeHandler, false, 0, true);
    }
    
    private function nestedChangeHandler(event:CollectionEvent):void
    {
      if (!_initialized)
        return;
      
      if (event.kind == CollectionEventKind.ADD) {
        var children:ArrayCollection = event.target as ArrayCollection;
        var childrenUID:String = UIDUtil.getUID(children);
        var parent:ComputerGroupVO = _childrenMap[childrenUID];
        
        for each (var child:ComputerGroupVO in event.items) {
          var oldParent:ComputerGroupVO = getParent(child);
          _parentMap[UIDUtil.getUID(child)] = parent;
          
          if (oldParent == null) {
            if (child.id != 0)
              _idMap[child.id] = child;
            child.children = new ArrayCollection();
            addTreeNode(child, parent);
          }
          else if (oldParent != parent) {
            var rpEvent:ComputerGroupTreeEvent;
            
            rpEvent = new ComputerGroupTreeEvent(ComputerGroupTreeEvent.TREE_REPARENT_GROUP, child, oldParent, parent);
            dispatchEvent(rpEvent);
          }
          
          if (parent != null)
            child.parent_id = parent.id
        }
      }
    }
  }
}
