package com.bigfix.extensions.controls.treeClasses
{
  import flash.events.MouseEvent;
  import mx.controls.Image;
  import mx.controls.CheckBox;
  import mx.controls.treeClasses.TreeItemRenderer;
  import mx.controls.treeClasses.ITreeDataDescriptor;
  import mx.controls.treeClasses.TreeListData;
  import com.bigfix.extensions.controls.CheckTree;
  
  public class CheckTreeRenderer extends mx.controls.treeClasses.TreeItemRenderer
  {
    [Embed(source="/assets/inner.png")]
    [Bindable]
    private var innerImg:Class;
  
    protected var myImage:Image;
    
    // set image properties
    private var imageWidth:Number = 6;
    private var imageHeight:Number  = 6;
    protected var myCheckBox:CheckBox;
    
    public function CheckTreeRenderer() 
    {
      super();
      mouseEnabled = false;
    }
    
    private function checkBoxToggleHandler(event:MouseEvent):void
    {
      if (data) {
        var tree:CheckTree = CheckTree(this.parent.parent);

        tree.setItemState(data,
                          myCheckBox.selected ? CheckTree.STATE_CHECKED 
                                              : CheckTree.STATE_UNCHECKED);
      }
    }
    
    private function imageToggleHandler(event:MouseEvent):void
    {
      myCheckBox.selected = !myCheckBox.selected;
      checkBoxToggleHandler(event);
    }
    
    override protected function createChildren():void
    {
      super.createChildren();
      myCheckBox = new CheckBox();
      myCheckBox.setStyle( "verticalAlign", "middle" );
      myCheckBox.addEventListener( MouseEvent.CLICK, checkBoxToggleHandler );
      addChild(myCheckBox);
      myImage = new Image();
      myImage.source = innerImg;
      myImage.addEventListener( MouseEvent.CLICK, imageToggleHandler );
      myImage.setStyle( "verticalAlign", "middle" );
      addChild(myImage);
    } 

    override public function set data(value:Object):void
    {
      super.data = value;

      if (value == null)
        return;
      
      var tree:CheckTree = CheckTree(this.parent.parent);
      var state:String = tree.getItemState(value);
      var treeData:ITreeDataDescriptor = tree.dataDescriptor;

      myCheckBox.selected = (state == CheckTree.STATE_CHECKED);

      if (treeData.isBranch(TreeListData(super.listData).item))
        tree.setStyle("defaultLeafIcon", null);
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
      var tree:CheckTree = CheckTree(this.parent.parent);

      super.updateDisplayList(unscaledWidth, unscaledHeight);
      if(super.data)
      {
        if (super.icon != null)
        {
          myCheckBox.x = super.icon.x;
          myCheckBox.y = 8;
          super.icon.x = myCheckBox.x + myCheckBox.width + 17;
          super.label.x = super.icon.x + super.icon.width + 3;
        }
        else
        {
          myCheckBox.x = super.label.x;
          myCheckBox.y = 8;
          super.label.x = myCheckBox.x + myCheckBox.width + 17;
        }

        if (tree.getItemState(data) == CheckTree.STATE_SCHRODINGER)
        {
          myImage.x = myCheckBox.x + 4;
          myImage.y = myCheckBox.y - 3;
          myImage.width = imageWidth;
          myImage.height = imageHeight;
        }
        else
        {
          myImage.x = 0;
          myImage.y = 0;
          myImage.width = 0;
          myImage.height = 0;
        }
      }
    }
  }
}
