#!/usr/bin/env perl

# vim: ai si sw=4 sts=4 et fdc=4 fmr=AAA,ZZZ fdm=marker

use warnings;
use strict;
use v5.22;
use experimental qw(signatures postderef smartmatch);

use Getopt::Long qw(:config no_ignore_case auto_help);
use Path::Tiny;
use JSON;
use Data::Printer;

my %opts = (empties => 0);
my @opts = ('empties');
GetOptions(\%opts, @opts) or die 'invalid option given', "\n";

my $input = shift or die 'no input file given', "\n";
my $output = path($input)->basename =~ s/\.(\w+)$/.json/r;

chomp (my @input_msgs = split /^\s*$/m, path($input)->slurp);
say 'msg count is ', scalar @input_msgs;

my %msgs;
for my $msg (@input_msgs) {
    my ($key, @lines) = grep {! /^$/} split /\n/, $msg;
    $key =~ s/^\s*|\s*$//g;
    if ($key) {
        if (@lines) {
            $msgs{$key}{msg} = [@lines];
        } else {
            $msgs{$key}{msg} = [] if $opts{empties};
            warn 'no msg body for key: ', $key , "\n";
        }
        $msgs{$key}{state} = '';
        $msgs{$key}{solved} = 0;
    }
}
say 'writing output to ', $output;
path($output)->spew(JSON->new->utf8->pretty->encode(\%msgs));
