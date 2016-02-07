#!/usr/bin/env perl

# vim: ai si sw=4 sts=4 et fdc=4 fmr=AAA,ZZZ fdm=marker

# normal junk #AAA
use warnings;
use strict;
use v5.18;
use experimental qw(smartmatch);

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

BEGIN {
    use experimental qw(smartmatch);
    unshift @INC, grep {! ($_ ~~ @INC)} map {"$_"} grep {path($_)->is_dir} map {path("$_/lib")->realpath} '.', '..';
}
use Menu;

#ZZZ

my @list = qw/this that and the other things/;

my $default = shift//undef;
say "default = $default";
my $prompt = $default ? "pick a word (default:=$list[$default-1])> " : 'pick >';
my $rtn = Menu::simple(default=>$default, prompt=>$prompt, data=>\@list);
$rtn ~~ [keys @list] ? say $list[$rtn] : die 'bad choice'

#my %menu;
#my @keys;
#while (my ($ndx, $val) = each (@list)) {
#    push @keys, "$ndx";
#    $menu{$ndx++} = $val;
#}
#
#my @rtn = Menu::complex( config=>{presets=>[0, 1]}, keys=>\@keys, data=>\%menu );
#
#say $menu{$_} for @rtn;
