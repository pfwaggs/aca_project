#!/usr/bin/env perl

# vim: ai si sw=4 sts=4 et fdc=4 fmr=AAA,ZZZ fdm=marker

# normal junk #AAA
use warnings;
use strict;
use v5.18;
use experimental qw(smartmatch);

use Path::Tiny;
use JSON::PP;
use Data::Printer;

BEGIN {
    use experimental qw(smartmatch);
    my @new_paths = map {path("$_/lib")->realpath} ('.', '..');
    @new_paths = map {"$_"} grep {path($_)->is_dir} @new_paths;
    unshift @INC, grep {! ($_ ~~ @INC)} @new_paths;
}
use Setup;
use Utilities;
use Ciphers::Mono;
use Stats;
use Menu;

our %config = Setup::init_Config();
$config{setup} = 'main';
warn 'showing config frm parser.pl';
p %config;

my $nl = "\n";

#ZZZ

my @new_paths = map {path("$_/etc")->realpath} ('.', '..');
@new_paths = map {"$_"} grep {path($_)->is_dir} @new_paths;
my ($p_rules) = grep {path($_)->is_file} map {"$_/parse_rules.jsn"} @new_paths;
our %parse_rules = Utilities::read_Json($p_rules);

# config_update #AAA
sub config_update {
    our %parse_rules;
    our %config;
    my %rules = %{$parse_rules{configs}};
    my @list = @{shift @_};
    for my $tag (@list) {
        my $key = $rules{$tag}{display};
        if ($rules{$tag}{type} eq 'toggle') {
            ($config{$key}) = grep {$_ ne $config{$key}} @{$rules{$tag}{values}};
        } else {
            my @menu = @{$rules{$tag}{values}};
            my @items = Menu::pick(@menu);
        }
    }
}
#ZZZ

# local_display #AAA
sub local_display {
    our %config;
    if ($_[0] eq 'debug') {
        warn 'local_display has this for config:';
        p %config;
        shift;
        say join(' : ', (caller(0))[0,1,2,3]);
    }
#   system('clear');
    #my @display = split /\s/, $_[0]->{display};
    my %cb = %Ciphers::Mono::callbacks;
    &{$cb{$_}}('debug', @_) for split /\s/, $config{display};
}
#ZZZ

# cipher_Pair_merge #AAA
sub cipher_Pair_merge {
    my %rtn = %{shift @_};
    for (map {split /:/} @{shift @_}) {
        my ($c, $p) = split //, uc $_;
        $rtn{$c} = $p;
    }
    return wantarray ? %rtn : \%rtn;
}
#ZZZ

# parse #AAA
sub parse {
    our %parse_rules;
    if ($_[0] eq 'debug') {
        shift;
        say join(' : ', (caller(0))[0,1,2,3]);
    }
    my @parts = @_;
    my %rtn;
    for my $type (keys %parse_rules) {
        p $parse_rules{$type};
        if (ref $parse_rules{$type}) {
            push @{$rtn{$type}}, grep {$_ ~~ $parse_rules{$type}} @parts;
        } else {
            push @{$rtn{$type}}, grep {$_ =~ qr/$parse_rules{$type}/} @parts;
        }
        @parts = grep {! ($_ ~~ $rtn{$type})} @parts;
    }
    $rtn{unknown} = [@parts];
    return %rtn;
}
#ZZZ

# hidden #AAA
#p %config;

my %msg = Utilities::read_Json(shift);

# the following bit just drills down to the actual msg we are working on
my @keys = keys %msg;
while (1 == @keys) {
    %msg = %{$msg{$keys[0]}};
    @keys = keys %msg;
}
#p %msg;
$msg{stats} = {Stats::mono_Stats($msg{msg})} unless exists $msg{stats};
$msg{state} = {map {$_=>' '} keys %{$msg{stats}{freqs}}}; # for testing we erase contents
#ZZZ

{
    #local_display(\%config, \%msg);
    local_display('debug', \%msg);
    print '> ';
    chomp(my $input=<STDIN>);
    my %current_parse = parse($input);
    warn 'config before update:';
    p %config;
    config_update($current_parse{configs}) if exists $current_parse{configs};
    warn 'config after update:';
    p %config;
    die;
    $msg{state} = cipher_Pair_merge($msg{state}, $current_parse{cp}) if exists $current_parse{cp};
    'quit' ~~ $current_parse{actions} ? last : redo;
}
