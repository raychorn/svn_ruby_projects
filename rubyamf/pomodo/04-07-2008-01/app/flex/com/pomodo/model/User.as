package com.pomodo.model {
    public class User {
        [Bindable]
        public var login:String;
        
        [Bindable]
        public var email:String;
        
        [Bindable]
        public var firstName:String;
        
        [Bindable]
        public var lastName:String;
        
        [Bindable]
        public var password:String;//to create user
        
        [Bindable]
        public var id:int;
        
        public function User(
            login:String = "",
            email:String = "",
            firstName:String = "",
            lastName:String = "",
            password:String = "",
            id:int = 0)
        {
            this.login = login;
            this.email = email;
            this.firstName = firstName;
            this.lastName = lastName;
            this.password = password;
            this.id = id;
        }

        public function toXML():XML {
            var retval:XML =
                <user>
                    <login>{login}</login>
                    <email>{email}</email>
                    <first_name>{firstName}</first_name>
                    <last_name>{lastName}</last_name>
                    <password>{password}</password>
       <password_confirmation>{password}</password_confirmation>
                </user>;
            return retval;
        }

        public static function fromXML(userXML:XML):User {
            return new User(
                userXML.login,
                userXML.email,
                userXML.first_name,
                userXML.last_name,
                "",
                userXML.id);
        }
    }
}