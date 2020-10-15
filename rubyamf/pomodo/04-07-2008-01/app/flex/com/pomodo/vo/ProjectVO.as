package com.pomodo.vo {
    [RemoteClass(alias='com.pomodo.vo.ProjectVO')]
    [Bindable]
    public class ProjectVO {
        public var id:int;
        public var name:String;
        public var notes:String;
        public var completed:Boolean;
    }
}