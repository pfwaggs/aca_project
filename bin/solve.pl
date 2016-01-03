#!/usr/bin/env perl

# vim: ai si sw=4 sts=4 et fdc=4 fmr=AAA,ZZZ fdm=marker

# normal junk #AAA
use warnings;
use strict;
use v5.18;

use Path::Tiny;
use JSON::PP;
use Data::Printer;

our $dir;
BEGIN {
    our $dir = Path::Tiny->cwd;
    $dir = path($dir)->parent if $dir =~ m{/bin$};
    $dir = path($dir)->stringify;
    unshift @INC, "$dir/lib" unless grep {/$dir/} @INC;
}
use Menu;
use Ciphers;
use Stats;

#ZZZ

my %solver = (
    A   => \&Ciphers::aristocrat_solver,
    HDL => \&Ciphers::headline_solver,
);

# read in the input file
my $input_file = shift;
my $jpp_in = JSON::PP->new->utf8;
my $name_map_file = "$dir/etc/name_map.jsn";
my %name_map = %{$jpp_in->decode(join(' ',path($name_map_file)->lines({chomp=>1})))};
my %msgs = %{$jpp_in->decode(join(' ',path($input_file)->lines({chomp=>1})))};

# msgs is organized as a hash of hashes.  the first hash is a family of
# messages (e.g. A [which is Aristocrats]) and within that is a hash of messages.
while (1) {
    my %found_families = map {$name_map{$_}{display} => $_} grep {exists $name_map{$_}} keys %msgs;
    my $ndx = 1;
    my %menu = map {$ndx++=>$_} sort keys %found_families; # an alphabetical sort of families
    my @keys = sort {$a <=> $b} keys %menu; # just sort the indices of %menu
    my ($family) = Menu::Pick({header=>'pick a family'}, {%menu, keys=>\@keys});
    last unless $family;
    $family = $found_families{$menu{$family}}; # this gets us back to hash key for msgs
    $msgs{$family} = $solver{$family}($msgs{$family});
}

my $output_file = '/tmp/check_orig.jsn';
my $jpp_out = JSON::PP->new->pretty->utf8;
path($output_file)->spew($jpp_out->encode(\%msgs));
