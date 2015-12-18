#!/usr/bin/env perl

# vim: ai si sw=4 sts=4 et fdc=4 fmr=AAA,ZZZ fdm=marker

# normal junk #AAA
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

#ZZZ

my $jpp_in = JSON::PP->new->utf8;
my $name_map_file = "$dir/etc/name_map.jsn";
my %name_map = %{$jpp_in->decode(join(' ',path($name_map_file)->lines({chomp=>1})))};
my %msgs = %{$jpp_in->decode(join(' ',path(shift)->lines({chomp=>1})))};

my @families = grep {exists $name_map{$_}} keys %msgs;
my @menu = map {$name_map{$_}{display}} @families;
my ($family) = Menu::Pick({header=>'pick a family'}, @menu);
$family = $families[$family];

my @msgs = sort {$a<=>$b} keys %{$msgs{$family}};
@menu = map {$msgs{$family}{$_}{msg}[0]} @msgs;
my ($msg) = Menu::Pick({header=>'pick a message'}, @menu);
$msg = $msgs[$msg];

$msgs{$family}{$msg} = Ciphers::aristocrat($msgs{$family}{$msg});
my %output;
$output{$family}{$msg} = $msgs{$family}{$msg};

my $jpp_out = JSON::PP->new->pretty->utf8;
path('temp_sols.jsn')->spew($jpp_out->encode(\%output));
