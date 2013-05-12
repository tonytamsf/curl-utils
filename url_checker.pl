#!/usr/local/bin/perl -w
# -*- Perl -*- 

# RCS info
#  $Author$
#  $Date$
#  $Id$
#  $Source$
#

use strict;
use LWP::Simple;

use lib '/home/yahoo/lib/perl';
use RunMutex qw[/tmp/.url_checker verbose];

=head1 NAME

C<url_checker> - run friedl page checker on dailynews and reports any missing tag errors

=cut

=head1 

=cut

my $S_url = shift;
unless(defined($S_url)) {
    print "Usage: url_checker.pl url\n";
    exit(1);
}
$S_url =~ s|http://||;

my $ADMIN = "page-tonytam\@yahoo-inc.com";
my $S_checker_url = 'http://checker.yahoo.com/check.cgi?url=http%3A%2F%2F'.
    ${S_url}.
    '%2F&TI=956345436&quick=1&lc=1&N0=Yahoo+Standard&Z=0&N1=More-Standard+Standard&L0=1&X0=1&L1=1&X1=1&U0=1&U1=1&I0=1&I1=1&O0=1&O1=1&MB0=A&MB1=A&V0=1&V1=1&SL0=0&SL1=0&H0=1&H1=1&Q1=0&Q0=1&A1=0&A0=1&E10=Y&E11=Y&P0=1&G0=0&G1=0&B0=U&B1=U&S=&F=79&EC=';

my $S_page = LWP::Simple::get($S_checker_url);
unless(defined($S_page)) {
    print "ERR: Unable to get $S_checker_url\n";
    exit(1);
}
my $S_error;
my $S_missing;
if ($S_page =~ /(Errors Noticed:\s+\d+)/) {
    $S_error = $1;
print "$S_error\n";
}

if ($S_page =~ /(Missing Tags Detected:\s+\d+)/) {
    $S_missing = $1;
print "$S_missing\n";
}

if ((defined($S_missing) && ($S_missing =~ /\S/)) ||
    (defined($S_error) && ($S_error   =~ /\S/))) {
    print "$S_checker_url\n";
}

sub alert_email
{
    my $S_mail_txt = shift;
    open(ALERT, "|/usr/sbin/sendmail -t");
    print ALERT "To:$ADMIN\n";
    print ALERT "Subject: ERR $S_url\n\n";
    print ALERT $S_mail_txt, "\n";
    close(ALERT);
}
1;

__END__
