class Auth < ServiceController
	def login(username, password)
		self.current_user = User.authenticate(username, password)
		checkLogin()
	end

	def checkLogin()
		if logged_in?
			# clean up old temp tables
			UserTempTable.destroy_all(['user_id = ? and session_id != ?', self.current_user.id, session.session_id])
			{ :success => true,
				:sessionID => session.session_id,
				:user => self.current_user,
				:permissions => { :admin => current_user.admin? }
			}
		else
			{ :success => false }
		end
	end

	def logoutDSS(sesisonID)
		self.current_user.forget_me if logged_in?
		self.current_user = nil
		{ :success => true }
	end
	
	def changePassword(old_password, new_password)
	  return { :success => false, :error => 'Not logged in.' } unless logged_in?
	  
	  return { :success => false, :error => 'Old password is incorrect.' } unless current_user.authenticated?(old_password)
	  
	  current_user.password = new_password
	  current_user.password_confirmation = new_password
	  current_user.save!
	  
	  { :success => true }
  end
end
