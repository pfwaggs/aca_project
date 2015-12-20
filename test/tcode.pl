#!/usr/bin/env perl

# vim: ai si sw=4 sts=4 et fdc=4 fmr=AAA,ZZZ fdm=marker

use warnings;
use strict;
use v5.18;
use Test::More tests => 8;

use Path::Tiny;
use JSON::PP;
use Data::Printer;

our $dir;
BEGIN {
    our $dir = Path::Tiny->cwd;
    $dir = path($dir)->parent if $dir =~ m{/(test|bin)$};
    $dir = path($dir)->stringify;
    unshift @INC, "$dir/lib" unless grep {/$dir/} @INC;
}
use Utilities;
use Stats;

my $file = 'tcode.jsn';
my $jpp_in = JSON::PP->new->utf8;
my %content = %{$jpp_in->decode(join(' ', path($file)->lines({chomp=>1})))};

my $_alpha = 'abcdefghijklmnopqrstuvwxyz';

# set up keyword based alphabet
my $key = $content{keyword};
my $deduped_want = $content{dedupe};
my $deduped_gen = Utilities::Dedupe($key);
is($deduped_gen, $deduped_want, 'deduped works');

# test construction of base alphabet on key value
my $alpha_want = $content{alpha};
my $alpha_gen = $deduped_gen.$_alpha =~ s/[$deduped_gen]//gr;
is($alpha_gen, $alpha_want, 'passed construction of base alphabet');

# check generation of hat values
my $hat = $content{hat};
my @numberfy_want = @{$content{hat_numbers}};
my @numberfy_gen = Utilities::Numberfy($hat);
is_deeply(\@numberfy_gen, \@numberfy_want, "correctly generated numbers from $hat");

# set up hat and write alphabet out on that width
my @width_want = @{$content{rows}};
my @width_gen = Utilities::On_width($alpha_gen,$hat);
is_deeply(\@width_gen, \@width_want, "passed width test for $alpha_gen and hat $hat");

# using the hat, extract columns based on hat then reassemble in hat order
my @decimate_want = @{$content{columns}};
my @decimate_gen = Utilities::Decimate($alpha_gen,$hat);
is_deeply(\@decimate_gen, \@decimate_want, 'passed test for decimate');

# testing setting construction
my $alpha = join('',@decimate_gen,@decimate_gen);
my $setting = $content{setting};
my @setting = split //, $setting;
my %hash_want = %{$content{setting_hash}};

my %hash_gen;
for my $ltr (split //, Utilities::Dedupe($setting)) {
    my $ndx = index($alpha,$ltr);
    $hash_gen{$ltr} = substr($alpha, $ndx, 26);
}
is_deeply(\%hash_gen, \%hash_want, 'passed test for setting');

my %msg = %{$content{msgs}{A}{1}};

my $passwd_want = $content{aca_passwd};
my $passwd_gen = lc substr($msg{msg}[0]=~s/\W//gr,0,7).'1';
is($passwd_gen, $passwd_want, 'passed password gen test');

my %stats_want = %{$content{stats}};
my %stats_gen = Stats::mono_counts($msg{msg});
is_deeply(\%stats_gen, \%stats_want, 'passed mono_counts stat check');

