#!/usr/bin/env perl

# vim: ai si sw=4 sts=4 et fdc=4 fmr=AAA,ZZZ fdm=marker

use warnings;
use strict;
use v5.18;

#use Getopt::Long qw( :config no_ignore_case auto_help );
#my %opts;
#my @opts;
#my @commands;
#GetOptions( \%opts, @opts, @commands ) or die 'something goes here';
#use Pod::Usage;
#use File::Basename;
#use Cwd;

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

my $jpp_in = JSON::PP->new->utf8;
my %msgs = %{$jpp_in->decode(join(' ',path(shift)->lines({chomp=>1})))};

my $name_map_file = "$dir/etc/name_map.jsn";
my %name_map = %{$jpp_in->decode(join(' ',path($name_map_file)->lines({chomp=>1})))};

my @families = grep {exists $name_map{$_}} keys %msgs;
my @menu = map {$name_map{$_}{display}} @families;
my ($family) = Menu::Pick({header=>'pick a family'}, @menu);
$family = $families[$family];

my @msgs = sort keys %{$msgs{$family}};
my ($msg) = Menu::Pick({header=>'pick a message'}, sort {$a<=>$b} @msgs);
$msg = $msgs[$msg];

my %freqs = %{$msgs{$family}{$msg}{state}};
my @keys = sort keys %freqs;
say join(' ', @keys);
say join(' ', @freqs{@keys});
say '';

@keys = sort {$freqs{$a} cmp $freqs{$b}} keys %freqs;
say join(' ', @keys);
say join(' ', @freqs{@keys});
say '';

#my %freqs_rev = (reverse %freqs);
#my @keys_rev = sort keys %freqs_rev;
#say join(' ', @keys_rev);
#say join(' ', @freqs_rev{@keys_rev});
