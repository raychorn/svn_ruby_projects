package com.pomodo.model {
    import com.pomodo.vo.NoteVO;

    public class Note {
        public function Note(content:String = "") {
            this.content = content;
        }
        
        [Bindable]
        public var content:String;

        public function toVO():NoteVO {
            var noteVO:NoteVO = new NoteVO();
            noteVO.content = content;
            return noteVO;
        }

        public static function fromVO(noteVO:NoteVO):Note {
            return new Note(noteVO.content);
        }
        
        public function toUpdateObject():Object {
            var obj:Object = new Object();
            obj["note[content]"] = content;
            return obj;
        }
        
        public static function fromXML(note:XML):Note {
            return new Note(note.content);
        }
    }
}