#!/usr/bin/perl -w
use strict;

use BigFixPM::net::www;

my $www = BigFixPM::net::www::new();

open FILE, "c:\\b.php";

my $data ="";

foreach (<FILE>){
    $data .=$_;
}

close FILE;

my $d = 'x' x (1024*8*8);

my $content = ['Username' => 'bigfix',
               'Password' => 'bigfix',
               'ReportID' => 89,
               'page' => 'EditStoredReport',
               'EditReportSubmit' => 1,
               'SaveReportName' => 'scratch',
               'ReportCategory' => 'Unknown',
               'ReportDescription' => 'Scratch',
               'SaveReportPublic' => 2,
               'ReportData' => $data];

my $code = $www->rawPost('http://pollo.bigfix.com/webreports',$content);

print "Pause";





