#!/usr/bin/env perl
#
# standings.pl - Main standings processor
#
# 2022 Ryan Thompson <rjt@cpan.org>

use 5.010;
use warnings;
use strict;
no warnings 'uninitialized';

use JSON;
use File::Slurper 'read_text';
use Data::Dump qw<dd pp>;
use autodie;

my %sheets = ingest('standings.json');

my @table = tally();

say '.------------------------------------+-------+-----+-----.';
printf "| %3s %-30s | %5s | %3s | %3s |\n",
    '', qw<Driver Total Spa RBR>;
say '|------------------------------------+-------+-----+-----|';
my ($pos, $pos_points) = (0,0);
for (@table) {
    ($pos, $pos_points) = ($pos + 1, $_->{points}) if $pos_points != $_->{points};
    printf "| %2d. %-30s | %5d | %3d | %3d |\n",
        $pos, $_->{driver_id}, $_->{points}, $_->{spa}, $_->{rbr};
}
say '`------------------------------------+-------+-----+-----\'';

#pp @table;

# Tally results into overall results table, one row for each driver
# { driver_id => "...", points => 122, rbr => 15, spa => 12, ... }
sub tally {
    my %drivers;
    for my $race (sort keys %{$sheets{Results}}) {
        for my $driver (sort keys %{$sheets{Results}{$race}}) {
            $drivers{$driver}{driver_id} = $driver;
            my $points = get_points($driver, $race);
            say "$driver got $points points at $race";
            $drivers{$driver}{$race} = $points;
            $drivers{$driver}{points} += $points;
        }
    }

    sort { $b->{points} <=> $a->{points} } values %drivers;
}

#pp \%sheets;

#
# Data access functions
#

# Get points for specific result
sub get_points {
    my ($driver_id, $race) = @_;
    my $rref = $sheets{Races}{$race};
    my $format = $rref->{format};

    my $res = $sheets{Results}{$race}{$driver_id};
    my ($pos1, $pos2) = ($res->{heat1_pos}, $res->{heat2_pos});
    say "$race: $format [P$pos1, P$pos2]";

    if ($format eq 'heat') {
        return $sheets{Points}{$pos1}{heat1}
            +  $sheets{Points}{$pos2}{heat2}
    } else {
        return $sheets{Points}{$pos1}{sprint}
    }

}

# Get a config variable
sub config {
    my $var = shift;
    die "Config variable `$var' does not exist"
        if not exists $sheets{Config}{$var};

    $sheets{Config}{$var}{val};
}


#
# Ingest/massage functions
#

# Main ingest function
sub ingest {
    my $standings = read_json('standings.json');
    my %r = get_sheets($standings);
    prune_drivers(\%r);
    $r{Results} = build_results(\%r);

    $r{Config} = _hashify(      var => $r{Config});
    $r{Races}  = _hashify(  race_id => $r{Races});
    $r{Points} = _hashify(   finish => $r{Points});
    $r{Drivers}= _hashify(driver_id => $r{Drivers});

    %r;
}

# Turn array into hash with single primary key
sub _hashify {
    my ($key, $ref) = @_;
    my $h = { map { $_->{$key} => $_ } @$ref }
}

# Build results hash
sub build_results {
    my $s = $_[0];
    my %r;
    for (@{$s->{Results}}) {
        $r{$_->{race_id}}->{$_->{driver_id}} =
            { heat1_pos => $_->{heat1_pos},
              heat2_pos => $_->{heat2_pos}
            };
    }
    \%r;
}

# Prune empty drivers from sheet
sub prune_drivers {
    my $s = $_[0];
    $s->{Drivers} = [ grep { $_->{driver_id} ne '' } @{$s->{Drivers}} ];
}

# Convert standings hash to hash of sheet names to HoH values
# e.g., $result->{Drivers}[0] = {
#       driver_id    => 'David Anderson',
#       display_name => undef,
#       number       => 278,
#       class        => 'Am',
#   }
sub get_sheets {
    my $standings = shift;
    my %r;
    for my $range (@{$standings->{valueRanges}}) {
        my $sheet = $range->{range};
        $sheet =~ s/!.*$//; # Trim range
        my @rows = $range->{values}->@*;
        my $header = shift @rows;
        my @cols = @$header;
        $r{$sheet} = [
            map {
                my @row = @$_;
                my $row = { map { $cols[$_] => $row[$_] } 0..$#row };
            } @rows
        ];
    }
    %r;
}

# Read JSON standings file and convert to Perl hashref
sub read_json {
    my $file = shift;
    my $raw = read_text($file);

    my $json = JSON->new->relaxed;

    $json->decode($raw);
}

