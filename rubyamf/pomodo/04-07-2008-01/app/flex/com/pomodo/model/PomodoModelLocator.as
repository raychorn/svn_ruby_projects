package com.pomodo.model {
    import com.adobe.cairngorm.model.IModelLocator;
    import com.pomodo.control.EventNames;
    import com.pomodo.util.CairngormUtils;
    import com.pomodo.validators.ServerErrors;
    import com.pomodo.vo.TaskVO;
    import com.pomodo.vo.ProjectVO;
    import com.pomodo.vo.LocationVO;
    
    import mx.collections.ArrayCollection;
    import mx.collections.ListCollectionView;

    [Bindable]
    public class PomodoModelLocator implements IModelLocator {
        //workflow states
        public static const VIEWING_SPLASH_SCREEN:int = 0;
        public static const VIEWING_MAIN_APP:int = 1;

        //
        //Public properties
        //
        public var user:User;
        
        public var note:Note;
        
        public var tasks:ListCollectionView;

        public var projects:ListCollectionView;

        public var locations:ListCollectionView;

        public var projectsAndNone:ListCollectionView;

        public var locationsAndNone:ListCollectionView;

        public var projectIDMap:Object;

        public var locationIDMap:Object;
        
        public var accountCreateErrors:ServerErrors;

        public var workflowState:int = VIEWING_SPLASH_SCREEN;

        public var reviews:String =
        '"pomodo, the hot new RIA by 38noises, is taking ' +
        'over Web 2.0." --Michael Arrington*\n"I wish I\'d ' +
        'invested in 38noises instead of that other company."' +
        ' --Jeff Bezos*\n"38noises closed angel funding at a ' +
        'party in my bathroom last night." --Om Malik*';

        public function updateTask(task:Task):void {
            for (var i:int = 0; i < tasks.length; i++) {
                var ithTask:Task = Task(tasks.getItemAt(i));
                if (ithTask.id == task.id) {
                    tasks.setItemAt(task, i);
                    break;
                }
            }
        }

        public function removeTask(task:Task):void {
            for (var i:int = 0; i < tasks.length; i++) {
                var ithTask:Task = Task(tasks.getItemAt(i));
                if (ithTask.id == task.id) {
                    ithTask.project.removeTask(ithTask);
                    ithTask.location.removeTask(ithTask);
                    tasks.removeItemAt(i);
                    break;
                }
            }
        }

        public function setTasksFromVOs(taskVOs:Array):void {
            var tasksArray:Array = [];
            for each (var item:TaskVO in taskVOs) {
                tasksArray.push(Task.fromVO(item));
            }
            tasks = new ArrayCollection(tasksArray);
        }

        public function setTasksFromList(list:XMLList):void {
            var tasksArray:Array = [];
            for each (var item:XML in list) {
                tasksArray.push(Task.fromXML(item));
            }
            tasks = new ArrayCollection(tasksArray);
        }

        public function setProjectsFromVOs(projectVOs:Array):
        void {
            var projectsArray:Array = [];
            for each (var item:ProjectVO in projectVOs) {
                projectsArray.push(Project.fromVO(item));
            }
            setProjects(projectsArray);
        }

        public function setProjectsFromList(list:XMLList):void {
            var projectsArray:Array = [];
            for each (var item:XML in list) {
                projectsArray.push(Project.fromXML(item));
            }
            setProjects(projectsArray);
        }

        public function setProjects(projectsArray:Array):void {
            projectIDMap = {};
            projectIDMap[0] = Project.NONE;
            for each (var project:Project in projectsArray) {
                projectIDMap[project.id] = project;
            }
            projects = new ArrayCollection(projectsArray);
            var projectsAndNoneArray:Array =
                projectsArray.slice(0);
            projectsAndNoneArray.splice(0, 0, Project.NONE);
            projectsAndNone =
                new ArrayCollection(projectsAndNoneArray);
            _gotProjects = true;
            listTasksIfMapsPresent();
        }

        public function setLocationsFromVOs(locationVOs:Array):
        void {
            var locationsArray:Array = [];
            for each (var item:LocationVO in locationVOs) {
                locationsArray.push(Location.fromVO(item));
            }
            setLocations(locationsArray);
        }

        public function setLocationsFromList(list:XMLList):
        void {
            var locationsArray:Array = [];
            for each (var item:XML in list) {
                locationsArray.push(Location.fromXML(item));
            }
            setLocations(locationsArray);
        }

        public function setLocations(locationsArray:Array):
        void {
            locationIDMap = {};
            locationIDMap[0] = Location.NONE;
            for each (var location:Location in locationsArray) {
                locationIDMap[location.id] = location;
            }
            locations = new ArrayCollection(locationsArray);
            var locationsAndNoneArray:Array =
                locationsArray.slice(0);
            locationsAndNoneArray.splice(0, 0, Location.NONE);
            locationsAndNone =
                new ArrayCollection(locationsAndNoneArray);
            _gotLocations = true;
            listTasksIfMapsPresent();
        }
        
        public function getProject(projectID:int):Project {
            if (projectIDMap == null) return null;
            return projectIDMap[projectID];
        }
    
        public function getLocation(locationID:int):Location {
            if (locationIDMap == null) return null;
            return locationIDMap[locationID];
        }
        
        //
        //Private variables
        //
        private var _gotProjects:Boolean;
    
        private var _gotLocations:Boolean;

        //
        //Private utility functions
        //
            
        private function listTasksIfMapsPresent():void {
            if (_gotProjects && _gotLocations) {
                CairngormUtils.dispatchEvent(
                    EventNames.LIST_TASKS);
            }
        }

        //
        //Singleton stuff
        //
        private static var modelLocator:PomodoModelLocator;

        public static function getInstance():PomodoModelLocator{
            if (modelLocator == null) {
                modelLocator = new PomodoModelLocator();
            }
            return modelLocator;
        }
        
        //The constructor should be private, but this is not
        //possible in ActionScript 3.0. So, throwing an Error if
        //a second PomodoModelLocator is created is the best we
        //can do to implement the Singleton pattern.
        public function PomodoModelLocator() {
            if (modelLocator != null) {
                throw new Error(
"Only one PomodoModelLocator instance may be instantiated.");
            }
            _gotProjects = false;
            _gotLocations = false;
        }
    }
}