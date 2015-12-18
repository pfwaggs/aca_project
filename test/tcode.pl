#!/usr/bin/env perl

# vim: ai si sw=4 sts=4 et fdc=4 fmr=AAA,ZZZ fdm=marker

use warnings;
use strict;
use v5.18;
use Test::More tests => 7;

use Path::Tiny;
#use JSON::PP;
#use Data::Printer;

our $dir;
BEGIN {
    our $dir = Path::Tiny->cwd;
    $dir = path($dir)->parent if $dir =~ m{/(test|bin)$};
    $dir = path($dir)->stringify;
    unshift @INC, "$dir/lib" unless grep {/$dir/} @INC;
}
use Utilities;

my $_alpha = 'abcdefghijklmnopqrstuvwxyz';

# set up keyword based alphabet
my $key = 'rosebudsled';
my $deduped_want = 'rosebudl';
my $deduped_gen = Utilities::Dedupe($key);
is($deduped_gen, $deduped_want, 'deduped works');

# test construction of base alphabet on key value
my $alpha_want = 'rosebudlacfghijkmnpqtvwxyz';
my $alpha_gen = $deduped_gen.$_alpha =~ s/[$deduped_gen]//gr;
is($alpha_gen, $alpha_want, 'passed construction of base alphabet');

# check generation of hat values
my $hat = 'mercury';
my @numberfy_want = qw(3 2 4 1 6 5 7);
my @numberfy_gen = Utilities::Numberfy($hat);
is_deeply(\@numberfy_gen, \@numberfy_want, "correctly generated numbers from $hat");

# set up hat and write alphabet out on that width
my @width_want = qw(rosebud lacfghi jkmnpqt vwxyz);
my @width_gen = Utilities::On_width($alpha_gen,$hat);
is_deeply(\@width_gen, \@width_want, "passed width test for $alpha_gen and hat $hat");

# using the hat, extract columns based on hat then reassemble in hat order
my @decimate_want = qw(efny oakw rljv scmx uhq bgpz dit);
my @decimate_gen = Utilities::Decimate($alpha_gen,$hat);
is_deeply(\@decimate_gen, \@decimate_want, 'passed test for decimate');

# testing setting construction
my $alpha = join('',@decimate_gen,@decimate_gen);
my $setting = 'alien';
my @setting = split //, $setting;
my %hash_want = (
    a => 'akwrljvscmxuhqbgpzditefnyo',
    l => 'ljvscmxuhqbgpzditefnyoakwr',
    i => 'itefnyoakwrljvscmxuhqbgpzd',
    e => 'efnyoakwrljvscmxuhqbgpzdit',
    n => 'nyoakwrljvscmxuhqbgpzditef',
);
my %hash_gen;
for my $ltr (split //, Utilities::Dedupe($setting)) {
    my $ndx = index($alpha,$ltr);
    $hash_gen{$ltr} = substr($alpha, $ndx, 26);
}
is_deeply(\%hash_gen, \%hash_want, 'passed test for setting');

my $file = 'temp_sols.jsn';
my $passwd_want = 'drupawx1';
my $passwd_gen = Utilities::Aca_password($file);
is($passwd_gen, $passwd_want, 'passed password gen test');
