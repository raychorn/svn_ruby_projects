package com.pomodo.vo {
    [RemoteClass(alias='com.pomodo.vo.TaskVO')]
    [Bindable]
    public class TaskVO {
        public var id:int;
        public var name:String;
        public var notes:String;
        public var projectId:int;
        public var locationId:int;
        public var nextAction:Boolean;
        public var completed:Boolean;
   }
}