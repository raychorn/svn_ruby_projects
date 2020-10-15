package com.pomodo.model {
    import mx.collections.ArrayCollection;
    import com.pomodo.util.XMLUtils;
    import com.pomodo.vo.ProjectVO;
    
    public class Project {
        public static const UNSAVED_ID:int = 0;
        public static const NONE_ID:int = 0;

        public static const NONE: Project =
            new Project("- None - ", "", false, NONE_ID);
        
        public function Project(
            name:String = "",
            notes:String = "",
            completed:Boolean = false,
            id:int = UNSAVED_ID)
        {
            this.name = name;
            this.notes = notes;
            this.completed = completed;
            this.id = id;
            tasks = new ArrayCollection([]);
        }
        
        [Bindable]
        public var id:int;

        [Bindable]
        public var name:String;
        
        [Bindable]
        public var notes:String;

        [Bindable]
        public var completed:Boolean;
        
        [Bindable]
        public var tasks:ArrayCollection;

        public function addTask(task:Task):void {
            task.project = this;
            tasks.addItem(task);
        }

        public function removeTask(task:Task):void {
            if (task.project == this) {
                for (var i:int = 0; i < tasks.length; i++) {
                    if (tasks[i].id == task.id) {
                        tasks.removeItemAt(i);
                        task.project = null;
                        break;
                    }
                }
            }
        }
        
        public function toVO():ProjectVO {
            var projectVO:ProjectVO = new ProjectVO();
            projectVO.id = id;
            projectVO.name = name;
            projectVO.notes = notes;
            projectVO.completed = completed;
            return projectVO;
        }

        public static function fromVO(projectVO:ProjectVO):
        Project {
            return new Project(
                projectVO.name,
                projectVO.notes,
                projectVO.completed,
                projectVO.id);
        }
        
        public function toUpdateObject():Object {
            var obj:Object = new Object();
            obj["project[name]"] = name;
            obj["project[notes]"] = notes;
            obj["project[completed]"] = completed;
            return obj;
        }
        
        public function toXML():XML {
            var retval:XML =
                <project>
                    <name>{name}</name>
                    <notes>{notes}</notes>
                    <completed>{completed}</completed>
                </project>;
            return retval;
        }
        
        public static function fromXML(proj:XML):Project {
            return new Project(
                proj.name,
                proj.notes,
                XMLUtils.xmlListToBoolean(proj.completed),
                proj.id);
        }
    }
}