begin
  require 'ldap'
rescue MissingSourceFile => e
  class LDAPAuth
    def self.get_instance
      nil
    end
  end
else
  class LDAPAuth
    def self.get_instance
      # XXX: Hardcoded.
      @instance ||= self.new('CN=Users,DC=bigfix,DC=com', 'bigdisk.bigfix.com')
    end
  
    def initialize(dn,host="localhost",port=389)
      @connection = nil
      @host = host
      @port = port
      @dn = dn
    end

    def login(login, password)
      begin
        conn = LDAP::Conn.new(@host, @port)
        conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
        conn.bind(login, password)
        @connection = conn
        return true
      rescue => e
        puts "e: #{e.inspect}"
        false
      end
    end

    def get_member_of(username)
      result = @connection.search2( @dn, LDAP::LDAP_SCOPE_SUBTREE, "cn=#{username}", ["memberOf"])
      members_of = Array.new
      result.first["memberOf"].each { |str|
      members_of << str.split(',')[0].split('=')[1]
      }
      members_of
    end

    def close
      @connection.unbind unless @connection == nil
      @connection = nil
    end
  end
end