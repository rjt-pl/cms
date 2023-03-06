#!/usr/bin/env perl
#
# irtes_reg_to_baserow.pl - Convert iRTES Excel to CSV for baserow
#
# This script takes the iRTES master registration Excel spreadsheet and
# exports the rows used by the baserow tables to two different CSV files
# These files can then be used with the "Import File" option on the
# related tables in baserow.
#
# 2023 Ryan Thompson <i@ry.ca>

use 5.010;
use warnings;
use strict;
no warnings 'uninitialized';
use autodie;

use Spreadsheet::ParseXLSX;
use Text::CSV qw< csv >;
use Data::Dump qw/dd pp/;
use List::Util qw<any all>;

# Columns from the input spreadsheet
my @labels = qw<class paid team_name iRacing_team_num tm 
    tm_num tm_discord tm_email car_choice
    car_number car_number_secondary driver_1 driver_1_num driver_2
    driver_2_num driver_3 driver_3_num driver_4 driver_4_num driver_5
    driver_5_num>;

my $file = shift or die "Usage: $0 file.xlsx";

output_tables(read_excel($file));

# Output both tables (we generate both simultaneously)
sub output_tables {
    my @teams = [qw<Team Car_Num Class TM TM_Discord>];
    my @drivers = [qw<Driver Team>];

    for (@_) {
        my %team = %$_;
        push @teams,   [ @team{qw<team_name car_number class tm tm_discord>} ];
        for (1..5) {
            my ($driver, $team) = @team{"driver_$_","team_name"};
            push @drivers, [ $driver, $team ] if ok_driver($driver);
        }
        push @drivers, [ "(other)", $team{team_name} ];

        say $team{tm_discord} if $team{tm_discord} !~ /^(.+?)#\d{4}$/;
    }

    csv( in => \@teams,   out => 'teams.csv',   encoding => 'UTF-8');
    csv( in => \@drivers, out => 'drivers.csv', encoding => 'UTF-8');

}

# Return true if supplied driver name is valid (we filter out obvious
# and known invalid things, such as blanks, "TBD", etc.
sub ok_driver {
    local $_ = shift;
    s/^\s+//, s/\s+$//; # Trim
    return if /^\s*$/;
    return if /^\(?\s*(TBD|BACKUP|none|pending)/i;
    return if m!^\(?\s*N/?A\s*\)?$!i;
    return if m!^N/|TB$!; # Special case typos

    1; # else
}

# Read the Excel spreadsheet, returning an aoh of the rows and
# columns, filtering out ones we don't use.
sub read_excel {
    my $file = shift;
    die "$file does not exist" unless -f $file;
    my $parser = Spreadsheet::ParseXLSX->new;
    my $workbook = $parser->parse($file);

    # We're looking for the first sheet
    my $ws = ($workbook->worksheets)[0];

    my ($row_min, $row_max) = $ws->row_range;
    my ($col_min, $col_max) = $ws->col_range;
    say "Rows[$row_min..$row_max], Cols[$col_min..$col_max]";

    my @list; # List of teams
    
    # Skip header row
    for my $row ($row_min+1 .. $row_max) {
        my @row;
        for my $col ($col_min .. $col_max) {
            my $cell = $ws->get_cell($row,$col);
            push @row, defined $cell ? $cell->value : undef;
        }

        # There's a blank row before totals; stop there
        last if all { $_ eq '' } @row;
        
        my %row;
        @row{@labels} = @row;

        push @list, \%row;
    }

    @list;
}

# Return an Excel-style cell index (B6) for a row and column
sub cell_num {
    my ($row, $col) = @_;
    my $last = chr($col % 26 + ord('A'));
    my $first = $col > 26 ? chr(int($col / 26) - 1 + ord('A')) : '';

    "$last$first$row [R$row, C$col]"
}
