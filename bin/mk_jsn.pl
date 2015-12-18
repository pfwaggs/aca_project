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

my @lines = map {s/^\s*|\s*$//gr} path(shift)->lines({chomp=>1});
my $base_name = shift @lines;
$base_name =~ s/\s+/_/g;

my %msgs;
my @meta;
my @msg;
for (@lines) {
    if (/\w/) {
        if(/^[[:alpha:]-]+-\d+\.$/) {
            push @meta, $_;
        } else {
            push @msg, $_;
        }
    } else {
        my ($meta) = 1 < @meta ? Menu::Pick(@meta) : $meta[0];
        my @meta_fields = split /\W/, $meta;
        my $key = pop @meta_fields;
        my $family = join('-',@meta_fields);
        $msgs{$family}{$key}{msg} = [@msg];
        $msgs{$family}{$key}{state} = undef;
        @meta = ();
        @msg = ();
    }
}
my $jpp = JSON::PP->new->utf8->pretty;
path("$base_name.jsn")->spew($jpp->encode(\%msgs));
