package com.bigfix.dss.model {
	import com.adobe.cairngorm.model.ModelLocator;
	import mx.collections.ICollectionView;
	import mx.collections.ArrayCollection;

	import com.bigfix.dss.vo.UserVO;
	import com.bigfix.dss.vo.WidgetVO;
	import com.bigfix.dss.vo.DashboardVO;
	import com.bigfix.dss.model.Constants;
	import com.bigfix.dss.model.ComputerGroupTree;

	import com.bigfix.dss.command.*;

	[Bindable]
	public class DSSModelLocator implements ModelLocator {
		// States
		public var viewState:String = 'Init'; // this is the view state of the root application
		public var workspaceViewState:String = 'Default'; // this is the view state of the main workspace under the control bar (post login)
		public var dashboardViewState:String = 'Main'; // this is the view state of the DashboardView.mxml (main dashboard interface)

		// which main tab in the workspace is active
		public var workspaceTabNavigatorSelectedIndex:int = Constants.WORKSPACE_DASHBOARDS;

		// session stuff
		public var user:UserVO;
		public var admin:Boolean; // Is the current user an administrator?
		public var sessionID:String;

	    // Configuration stuff
	    [ArrayElementType("com.bigfix.dss.vo.UserVO")]
	    public var users:ArrayCollection;
    
	    [ArrayElementType("com.bigfix.dss.vo.RoleVO")]
	    public var roles:ArrayCollection;

	    [ArrayElementType("com.bigfix.dss.vo.ContactVO")]
	    public var contacts:ArrayCollection;
	    
	    [ArrayElementType("com.bigfix.dss.vo.DatasourceComputerGroupVO")]
	    public var datasourceComputerGroups:ArrayCollection;

		// Reporting Catalog
		[ArrayElementType("com.bigfix.dss.vo.SubjectVO")]
		public var subjects:ArrayCollection;
		[ArrayElementType("com.bigfix.dss.vo.PropertyOperatorVO")]
		public var property_operators:ArrayCollection;
		[ArrayElementType("com.bigfix.dss.vo.VisualizationTypeVO")]
		public var visualization_types:ArrayCollection;
		[ArrrayElementType("com.bigfix.dss.vo.ComputerGroupDistributionVO")]
		public var computer_group_distributions:ArrayCollection;
		[ArrrayElementType("com.bigfix.dss.vo.AggregateFunctionVO")]
		public var aggregate_functions:ArrayCollection;

		// dashboard stuff
		[ArrayElementType("com.bigfix.dss.vo.DashboardVO")]
		public var dashboards:ArrayCollection; // dashboards for this user, this is used only for inital loading and will become out of sync
		[ArrayElementType("com.bigfix.dss.vo.DashboardLayoutVO")]
		public var dashboard_layouts:ArrayCollection; // dashboard Layouts
		[ArrayElementType("com.bigfix.dss.vo.WidgetVO")]
		public var widgets:ArrayCollection; // all widgets which this user has defined
		
		// 'currentDashboard' represents a dashboard which the user is editing or creating
		public var currentDashboard:DashboardVO;
		// 'currentWidget' represents a widget which the user is editing or creating
		public var currentWidget:WidgetVO;

		// filter being used in widget library
		public var currentSearchText:String;

		// viewstate to return to
		public var previousDashboardViewState:String = 'Main';
		
		// analysis stuff
		public var currentAnalysisOptions:*;

		// reporting stuff. this should eventully be typed to ReportVOs
		[ArrayElementType('com.bigfix.dss.vo.ReportVO')]
		public var reports:ArrayCollection;
		
		// reports reports currently selected in the Report Management View
		[ArrayElementType('com.bigfix.dss.vo.ReportVO')]
		public var currentReports:Array;

		// general stuff
		public function get computer_group_tree():ArrayCollection
		{
		  return computerGroupTree.root.children;
		}
		
		// Yes, we really do have two members of the model named "computer group tree",
		// one underscored and one CamelCased.  The first one is needed for backwards
		// compatibility with older code, for the moment.
		public var computerGroupTree:ComputerGroupTree;

		// XXX: This function should be replaced with something that automatically
		// pluralizes the name and fetches the appropriate property.
		public function getObjectsByClassName(objectClass:String):ArrayCollection
		{
		  switch (objectClass) {
		    case "Role":
		      return roles;
		    case "User":
		      return users;
		    case "Contact":
		      return contacts;
		    case "DatasourceComputerGroup":
		      return datasourceComputerGroups;
		    default:
		      throw new Error("Unknown class '" + objectClass + "'");
		  }
		}

		// XXX: This function should be replaced with something that automatically
		// pluralizes the name and sets the appropriate property.
		public function setObjectsByClassName(objectClass:String, objs:ArrayCollection):void
		{
		  switch (objectClass) {
		    case "Role":
		      roles = objs;
		      break;
		    case "User":
		      users = objs;
		      break;
		    case "Contact":
		      contacts = objs;
		      break;
		    case "DatasourceComputerGroup":
		      datasourceComputerGroups = objs;
		      break;
		    default:
		      throw "Unknown class '" + objectClass + "'";
		  }
		}

		private static var modelLocator:DSSModelLocator;

		public static function getInstance():DSSModelLocator {
			if (modelLocator == null) {
				modelLocator = new DSSModelLocator();
			}
			return modelLocator;
		}

		public function DSSModelLocator() {
			if (modelLocator != null) {
				throw new Error("Only one DSSModelLocator instance should be instantiated");
			}
		}
	}
}
