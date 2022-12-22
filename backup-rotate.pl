#!/usr/bin/env perl
#
# backup-rotate.pl - Rotate CMS backups on Amazon S3
#
# 2022 Ryan Thompson <rjt@cpan.org>

use 5.010;
use warnings;
use strict;
no warnings 'uninitialized';

use Getopt::Long;
use List::Util qw<min max>;

my %o = (
    bucket  => 'cmsracing-backup',
    recent  => 14,
);

# Read and sort file list by date/time
my @f = sort { $b->{date} cmp $a->{date} || $b->{time} cmp $a->{time} }
        map  {
            chomp;
            s!s3://[^/]+/!!g;
            my %r; @r{qw<date time size file>} = (split /\s+/, $_, 4);
            \%r; 
        } `s3cmd ls s3://$o{bucket}/`;

my @del = @f[$o{recent}..$#f];

preflight();

system "s3cmd del s3://$o{bucket}/$_->{file}" for @del;

# Preflight dry run output.
# TODO - This can be disabled or removed once we've done $o{recent}+1 backups
sub preflight {
    say "All files:";
    ls(1,@f);
    say '';

    say "Deleting:";
    ls($o{recent}+1,@del);
}

# Pretty print file list
sub ls {
    my $c = shift;
    printf "%3s. %10s %5s %10s %s\n", $c++, @{$_}{qw<date time size file>} for @_;
}
