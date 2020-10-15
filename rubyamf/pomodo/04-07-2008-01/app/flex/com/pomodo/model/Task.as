package com.pomodo.model {
    import com.pomodo.util.XMLUtils;
    import com.pomodo.vo.TaskVO;
    
    public class Task {
        public static const UNSAVED_ID:int = 0;

        [Bindable]
        public var id:int;
        
        [Bindable]
        public var name:String;
        
        [Bindable]
        public var notes:String;

        [Bindable]
        public var project:Project;
        
        [Bindable]
        public var location:Location;
        
        [Bindable]
        public var nextAction:Boolean;

        [Bindable]
        public var completed:Boolean;

        public function Task(
            name:String = "",
            notes:String = "",
            project:Project = null,
            location:Location = null,
            nextAction:Boolean = false,
            completed:Boolean = false,
            id:int = UNSAVED_ID)
        {
            this.name = name;
            this.notes = notes;
            if (project == null) {
                project = Project.NONE;
            }
            project.addTask(this);
            if (location == null) {
                location = Location.NONE;
            }
            location.addTask(this);
            this.nextAction = nextAction;
            this.completed = completed;
            this.id = id;
        }
        
        public function toVO():TaskVO {
            var taskVO:TaskVO = new TaskVO();
            taskVO.id = id;
            taskVO.name = name;
            taskVO.projectId = project.id;
            taskVO.locationId = location.id;
            taskVO.nextAction = nextAction;
            taskVO.completed = completed;
            taskVO.notes = notes;
            return taskVO;
        }

        public static function fromVO(taskVO:TaskVO):Task {
            var model:PomodoModelLocator =
                PomodoModelLocator.getInstance();
            return new Task(
                taskVO.name,
                taskVO.notes,
                model.getProject(taskVO.projectId),
                model.getLocation(taskVO.locationId),
                taskVO.nextAction,
                taskVO.completed,
                taskVO.id);
        }

        public function toUpdateObject():Object {
            var obj:Object = new Object();
            obj["task[name]"] = name;
            obj["task[project_id]"] = project.id;
            obj["task[location_id]"] = location.id;
            obj["task[next_action]"] = nextAction;
            obj["task[completed]"] = completed;
            obj["task[notes]"] = notes;
            return obj;
        }
        
        public function toXML():XML {
            var retval:XML =
                <task>
                    <name>{name}</name>
                    <notes>{notes}</notes>
                    <project_id>{project.id}</project_id>
                    <location_id>{location.id}</location_id>
                    <next_action>{nextAction}</next_action>
                    <completed>{completed}</completed>
                </task>;
            return retval;
        }
        
        public static function fromXML(taskXML:XML):Task {
            var model:PomodoModelLocator =
                PomodoModelLocator.getInstance();
            return new Task(
                taskXML.name,
                taskXML.notes,
                model.getProject(taskXML.project_id),
                model.getLocation(taskXML.location_id),
                XMLUtils.xmlListToBoolean(taskXML.next_action),
                XMLUtils.xmlListToBoolean(taskXML.completed),
                taskXML.id);
        }
    }
}