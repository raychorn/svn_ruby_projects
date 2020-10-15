package com.bigfix.dss.vo
{
	import com.bigfix.dss.vo.IEditableObject;
	import com.adobe.fileformats.vcard.*;
	import com.bigfix.fileformats.vcard.*;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.Contact")]
	public class ContactVO implements IEditableObject {
		public var id:int;
		public var user_id:int;

    [Transient]
		public var _vcard:String;
		
		[Transient]
		private var _vcardObj:VCard;
		
		public function get vcard():String {
		  if (_vcardObj != null)
		    _vcard = VCardWriter.write(_vcardObj);
		  
		  return _vcard;
		}
		
		public function set vcard(vcard:String):void {
		  _vcard = vcard;
		  _vcardObj = null;
		}
		
		[Transient]
		public function get vcardObj():VCard
		{
		  if (_vcardObj == null) {
		    var vcards:Array = VCardParser.parse(vcard);
		    
		    if (vcards.length > 0)
		      _vcardObj = vcards[0];
		    else
		      _vcardObj = new VCard();
		  }
		  
		  return _vcardObj;
		}

    [Transient]
    public function get name():String
    {
      return vcardObj.fullName;
    }
    
    public function set name(n:String):void
    {
      vcardObj.fullName = n;
    }
    
    [Transient]
    public function get email():String
    {
      if (vcardObj.emails.length > 0)
        return vcardObj.emails[0].address;
      else
        return '';
    }
    
    public function set email(addr:String):void
    {
      if (vcardObj.emails.length == 0) {
        vcardObj.emails = [new Email()];
        vcardObj.emails[0].type = 'work';
      }
        
      vcardObj.emails[0].address = addr;
    }
    
    [Transient]
    public function get phone():String
    {
      if (vcardObj.phones.length > 0)
        return vcardObj.phones[0].number;
      else
        return '';
    }
		
    public function set phone(number:String):void
    {
      if (vcardObj.phones.length == 0) {
        vcardObj.phones = [new Phone()];
        vcardObj.phones[0].type = 'work';
      }
        
      vcardObj.phones[0].number = number;
    }
    
		[Transient]
		public var busy:Boolean;

    public function update(newContact:IEditableObject):void
    {
      id = newContact.id;
      user_id = ContactVO(newContact).user_id;
      vcard = ContactVO(newContact).vcard;
    }
	}
}
