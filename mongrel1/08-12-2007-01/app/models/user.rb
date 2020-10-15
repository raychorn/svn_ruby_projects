require 'digest/sha1'
require 'editor_support'

class User < ActiveRecord::Base
	has_and_belongs_to_many :roles
	has_many :dashboards, :order => 'position'
    has_many :reports

	# Virtual attribute for the unencrypted password
	attr_accessor :password

	validates_presence_of     :username, :name, :email
	validates_presence_of     :password,                   :if => :password_required?
	validates_presence_of     :password_confirmation,      :if => :password_required?
	validates_length_of       :password, :within => 4..40, :if => :password_required?
	validates_confirmation_of :password,                   :if => :password_required?
	validates_length_of       :username, :within => 3..40
	validates_length_of       :email,    :within => 3..100
	validates_uniqueness_of   :username, :email, :case_sensitive => false
	before_save :encrypt_password

	attr_accessible :password, :password_confirmation, :username, :name, :email
	editable

	def editor_attributes
		allowed_attributes = %w(id username name email)
		returning attrs = attributes do
			attrs.keys.each { |key| attrs.delete key unless allowed_attributes.include?(key) }
		end
	end

	def admin?
	  if @admin.nil?
		  @admin = !roles.find(:first, :conditions => { :admin => true }).nil?
	  end
	  
	  @admin
	end

  def self.user_find_options(user, options)
  	# Admins can see everyone.
  	# Other users can only see themselves.

		return options if user.nil? || user.admin?

    returning options do
      if options[:conditions]
        options[:conditions] = sanitize_sql options[:conditions] + " AND "
      else
        options[:conditions] = ''
      end
      options[:conditions] += "users.id = #{user.id}"
    end
  end

	def is_viewable_by?(user)
		user == self || user.admin?
	end

	def is_editable_by?(user)
		user == self || user.admin?
	end

	def is_deleteable_by?(user)
		user != self && user.admin?
	end
	
	def property_is_viewable_by?(property_name, user)
	  super(property_name, user) || property_name == 'role_ids' || property_name == 'roles'
  end
  
  def property_is_editable_by?(property_name, user)
    super(property_name, user) || ((property_name == 'role_ids' || property_name == 'password' || property_name == 'password_confirmation') && user.admin?)
  end

	# Authenticates a user by their username and unencrypted password.  Returns the user or nil.
	def self.authenticate(username, password)
		u = find_by_username(username) # need to get the salt
		u && u.authenticated?(password) ? u : nil
	end

	# Encrypts some data with the salt.
	def self.encrypt(password, salt)
		Digest::SHA1.hexdigest("--#{salt}--#{password}--")
	end

	def self.content_columns
		non_content_columns = Set.new %w(hashed_password salt remember_token_expires_at remember_token)
		super.find_all { |c| !non_content_columns.include? c.name }
	end

	# Encrypts the password with the user salt
	def encrypt(password)
		self.class.encrypt(password, salt)
	end

  def ldap_username
    # XXX should be a real attribute
    #return 'brian_buchanan@bigfix.com' if username == 'brian'
  end

  def authenticated?(password)
    if ldap_username && (auth = LDAPAuth.get_instance)
      auth.login(ldap_username, password)
    else
      hashed_password == encrypt(password)
    end
  end

	def remember_token?
		remember_token_expires_at && Time.now.utc < remember_token_expires_at
	end

	# These create and unset the fields required for remembering users between browser closes
	def remember_me
		remember_me_for 2.weeks
	end

	def remember_me_for(time)
		remember_me_until time.from_now.utc
	end

	def remember_me_until(time)
		self.remember_token_expires_at = time
		self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
		save(false)
	end

	def forget_me
		self.remember_token_expires_at = nil
		self.remember_token            = nil
		save(false)
	end

	protected

	# before filter
	def encrypt_password
		return if password.blank?
		self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{username}--") unless salt?
		self.hashed_password = encrypt(password)
	end

	def password_required?
		hashed_password.blank? || !password.blank?
	end
end
