package com.pomodo.model {
    import mx.collections.ArrayCollection;
    import com.pomodo.vo.LocationVO;
    
    public class Location {
        public static const UNSAVED_ID:int = 0;
        public static const NONE_ID:int = 0;

        public static const NONE: Location =
            new Location("- None - ", "", NONE_ID);

        public function Location(
            name:String = "",
            notes:String = "",
            id:int = UNSAVED_ID)
        {
            this.name = name;
            this.notes = notes;
            this.id = id;
            tasks = new ArrayCollection([]);
        }
        
        [Bindable]
        public var id: int;

        [Bindable]
        public var name:String;
        
        [Bindable]
        public var notes:String;

        [Bindable]
        public var tasks: ArrayCollection;

        public function addTask(task:Task):void {
            task.location = this;
            tasks.addItem(task);
        }

        public function removeTask(task:Task):void {
            if (task.location == this) {
                for (var i:int = 0; i < tasks.length; i++) {
                    if (tasks[i].id == task.id) {
                        tasks.removeItemAt(i);
                        task.location = null;
                        break;
                    }
                }
            }
        }

        public function toVO():LocationVO {
            var locationVO:LocationVO = new LocationVO();
            locationVO.id = id;
            locationVO.name = name;
            locationVO.notes = notes;
            return locationVO;
        }

        public static function fromVO(locationVO:LocationVO):
        Location {
            return new Location(
                locationVO.name,
                locationVO.notes,
                locationVO.id);
        }

        public function toUpdateObject():Object {
            var obj:Object = new Object();
            obj["location[name]"] = name;
            obj["location[notes]"] = notes;
            return obj;
        }

        public function toXML():XML {
            var retval:XML =
                <location>
                    <name>{name}</name>
                    <notes>{notes}</notes>
                </location>;
            return retval;
        }
        
        public static function fromXML(loc:XML):Location {
            return new Location(loc.name, loc.notes, loc.id);
        }
    }
}