package com.bigfix.fileformats.vcard
{
	import mx.utils.StringUtil;
	import com.adobe.fileformats.vcard.*;
	
	public class VCardWriter {
	  public static function write(vcard:VCard):String
	  {
	    var vcstr:String = "BEGIN:VCARD\nVERSION:3.0\n";
	    
	    if (vcard.orgs != null && vcard.orgs.length != 0)
	      vcstr += "ORG:" + vcard.orgs.join(';') + "\n";
	      
	    if (vcard.title != null)
	      vcstr += "TITLE:" + vcard.title + "\n";
	      
	    if (vcard.fullName != null)
	      vcstr += "FN:" + vcard.fullName + "\n";
	    
	    if (vcard.phones != null) {
	      for each (var phone:Phone in vcard.phones) {
	        // XXX: Does not set "pref" for preferred phone.
	        vcstr += "TEL;type=" + phone.type + ":" + phone.number + "\n";
        }
	    }
	    
	    if (vcard.emails != null) {
	      for each (var email:Email in vcard.emails) {
	        // XXX: Does not set "pref" for preferred email.
	        vcstr += "EMAIL;type=INTERNET;type=" + email.type + ":" + email.address + "\n";
	      }
	    }
	    
	    if (vcard.addresses != null) {
	      for each (var addr:Address in vcard.addresses) {
	        // XXX: Does not set "pref" for preferred address.
	        vcstr += "ADR;type=" + addr.type + ":;;" + addr.street + ";" + addr.city + ";" + addr.state + ";" + addr.postalCode + "\n";
	      }
	    }
	    
	    // XXX: Encode PHOTO if present
	    
	    vcstr += "END:VCARD\n";
	    return vcstr;
	  }
	}
}
