package com.pomodo.control {
	import com.adobe.cairngorm.control.FrontController;
    import com.pomodo.control.EventNames;
    import com.pomodo.command.*;

    public class PomodoController extends FrontController {
        public function PomodoController() {
            initializeCommands();
        }
        
        private function initializeCommands():void {
            addCommand(EventNames.CREATE_LOCATION,
                CreateLocationCommand);
            addCommand(EventNames.CREATE_PROJECT,
                CreateProjectCommand);
            addCommand(EventNames.CREATE_SESSION,
                CreateSessionCommand);
            addCommand(EventNames.CREATE_TASK,
                CreateTaskCommand);
            addCommand(EventNames.CREATE_USER,
                CreateUserCommand);

            addCommand(EventNames.DESTROY_LOCATION,
                DestroyLocationCommand);
            addCommand(EventNames.DESTROY_PROJECT,
                DestroyProjectCommand);
            addCommand(EventNames.DESTROY_TASK,
                DestroyTaskCommand);
            addCommand(EventNames.DESTROY_USER,
                DestroyUserCommand);

            addCommand(EventNames.LIST_LOCATIONS,
                ListLocationsCommand);
            addCommand(EventNames.LIST_PROJECTS,
                ListProjectsCommand);
            addCommand(EventNames.LIST_TASKS,
                ListTasksCommand);

            addCommand(EventNames.UPDATE_LOCATION,
                UpdateLocationCommand);
            addCommand(EventNames.UPDATE_PROJECT,
                UpdateProjectCommand);
            addCommand(EventNames.UPDATE_TASK,
                UpdateTaskCommand);
            addCommand(EventNames.UPDATE_NOTE,
                UpdateNoteCommand);

            addCommand(EventNames.SHOW_NOTE, ShowNoteCommand);
            addCommand(EventNames.LOAD_URL, LoadURLCommand);
        }
    }
}
