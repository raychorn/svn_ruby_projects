#!/usr/bin/perl -w
use strict;

package BigFixPM::net::www;

use BigFixPM::util::genericUtil;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST GET);
use HTTP::Cookies;
use URI::Escape;

# Parameters:
# -ua        => Existing UA Object
# -proxyurl  => proxy url (url:port)
# -proxyuser => proxy user
# -proxypass => proxy password
# 
sub new {
    my $this;
    
     my $args = parameterMap(@_);
    
    $this = {
        'UA' => undef,
        'PROXY' => { # PROXY INFO
                    'ENABLED' => 0,
                    'AUTH' => 0,                    
                    'URL' => '',
                    'USER' => '',
                    'PASSWORD' => '',
                   },
        'URL' => undef,
        'REQUEST' => undef,
        'RESPONSE' => undef,
    };
    
    bless $this;
    
    if (defined $args->{UA}){
        $this->{UA}=$args->{UA};
    } else {
        $this->{UA} = LWP::UserAgent->new();
        $this->{UA}->cookie_jar(HTTP::Cookies->new());
    }
    
    if (defined $args->{proxyurl}){
        $this->{PROXY}->{ENABLED} = 1;
        $this->{PROXY}->{URL}=$args->{PROXYURL};
        if (defined $args->{proxyuser} || defined $args->{proxypass}){
          $this->{PROXY}->{AUTH} = 1;
          $this->{PROXY}->{USER} = $args->{PROXYUSER};
          $this->{PROXY}->{PASSWORD} = $args->{PROXYPASS};
        } 
    }
    
    return $this;
}

sub usingProxy { return (shift)->{PROXY}->{ENABLED}; }
sub usingProxyAuth { return (shift)->{PROXY}->{AUTH}; }
sub getProxyURL { return (shift)->{PROXY}->{URL}; }
sub getContent { return (shift)->response->content; }

sub ua { return (shift)->{UA}; }
sub request { return (shift)->{REQUEST}; }
sub response { return (shift)->{RESPONSE}; }

# parameters: url
sub get {
    my $this = shift;
    my $url = shift;
    
    $this->{URL} = $url;
    
    $this->{REQUEST} = GET $url, @_;
    
    if ($this->usingProxy){
        $this->ua->proxy(['http', 'ftp'], $this->{PROXY}->{URL});
        if ($this->usingProxyAuth){
            $this->request->proxy_authorization_basic($this->{PROXY}->{USER}, $this->{PROXY}->{PASS});
        }
    } 
    
    $this->{RESPONSE} = $this->ua->request($this->request);
    
    return $this->response->code;
}

sub rawPost {
    my $this = shift;
    my $url = shift;
    my $content = shift;
    
    $this->{REQUEST} = POST $url,$content;

    return $this->_makeRequest;    
}

sub post {
    my $this = shift;
    my $url = shift;
    
    $this->{REQUEST} = POST $url, @_;
    
    return $this->_makeRequest;
}

sub _makeRequest {
    my $this = shift;
    
    if ($this->usingProxy){
        $this->ua->proxy(['http', 'ftp'], $this->{PROXY}->{URL});
        if ($this->usingProxyAuth){
            $this->request->proxy_authorization_basic($this->{PROXY}->{USER}, $this->{PROXY}->{PASS});
        }
    }
    
    $this->{RESPONSE} = $this->ua->request($this->request);
    
    return $this->response->code;    
    
}

1;

__END__