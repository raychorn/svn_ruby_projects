package com.bigfix.dss.control
{
	import com.adobe.cairngorm.control.FrontController;
	import com.bigfix.dss.event.*;
	import com.bigfix.dss.command.*;

	public class DSSController extends FrontController
	{
		public function DSSController() {
			initializeCommands();
		}

		public function initializeCommands():void {
			addCommand(LoginEvent.EVENT_LOGIN, LoginCommand);
			addCommand(GetCatalogEvent.EVENT_GET_CATALOG, GetCatalogCommand);
			addCommand(LogoutEvent.EVENT_LOGOUT, LogoutCommand);
			addCommand(CreatePopUpEvent.EVENT_CREATE_POPUP, CreatePopUpCommand);
			addCommand(GetComputerGroupTreeEvent.EVENT_GET_COMPUTER_GROUP_TREE, GetComputerGroupTreeCommand);
			addCommand(RefreshComputerGroupTreeEvent.EVENT_REFRESH_COMPUTER_GROUP_TREE, GetComputerGroupTreeCommand);
			addCommand(RefreshWidgetsEvent.EVENT_REFRESH, GetWidgetsCommand);
			addCommand(RefreshDashboardsEvent.EVENT_REFRESH_DASHBOARDS, GetDashboardsCommand);
			addCommand(GetReportsEvent.EVENT_GET_REPORTS, GetReportsCommand);
			addCommand(ComputerGroupEvent.DELETE_GROUPS, DeleteComputerGroupsCommand);
			addCommand(EditorEvent.EDITOR_LIST, EditorListCommand);
			addCommand(EditorEvent.EDITOR_CREATE, EditorCreateCommand);
			addCommand(EditorEvent.EDITOR_UPDATE, EditorUpdateCommand);
			addCommand(EditorEvent.EDITOR_DELETE, EditorDeleteCommand);
			addCommand(ChangePasswordEvent.CHANGE_PASSWORD, ChangePasswordCommand);
			addCommand(SetReportScheduleEvent.EVENT_SET_REPORT_SCHEDULE, SetReportScheduleCommand);
		}
	}
}
