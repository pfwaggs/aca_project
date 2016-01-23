#!/usr/bin/env perl

# vim: ai si sw=4 sts=4 et fdc=4 fmr=AAA,ZZZ fdm=marker

# #AAA normal junk 
use warnings;
use strict;
use v5.18;

use Path::Tiny;
use JSON::PP;
use Data::Printer;

BEGIN {
    use experimental qw(smartmatch);
    my @libs = map {"$_"} map {path("$_/lib")->realpath} grep {path("$_/lib")->is_dir} qw/. ../;
    push @INC, grep {! ($_ ~~ @INC)} @libs;
}
use Menu;

#ZZZ

# read in names mapping jsn file
my $jpp_in = JSON::PP->new->utf8;
my ($name_map_file) = map {path("$_/names.jsn")->realpath} grep {path("$_/names.jsn")->is_file} qw(. ../etc);
my %name_map = %{$jpp_in->decode(join(' ',path($name_map_file)->lines({chomp=>1})))};
my $name_map_max = pop [sort {$a <=> $b} map {length $_} values %name_map];

# #AAA display 
sub display {
    my %tmsg = @_;
    say for @{$tmsg{msg}};
}
#ZZZ

# #AAA %solvers 
# want to abstract this external to script
my %solvers = (
    A => \&Ciphers::monoalphabetic_solver,
    default => \&display,
);
#ZZZ

# #AAA get_family 
# this has some global vars; name_map and name_map_max
sub get_family {
    my %hash = %{shift @_};
    my @keys = sort keys %hash;

    my @menu;
    for my $key (@keys) {
        my @count = sort keys %{$hash{$key}};
        my $solved = grep {$hash{$key}{solved}} @count;
        push @menu, sprintf "%*s : (%d/%d)", $name_map_max, $name_map{$key}//$key, $solved, scalar @count;
    }

    my ($choice) = Menu::simple('pick a family> ', @menu);
    return -1 == $choice ? () : ($solvers{$keys[$choice]}//$solvers{default}, %{$hash{$keys[$choice]}});
}
#ZZZ

# #AAA get_msg 
sub get_msg {
    my %messages = %{shift @_};
    my @message_numbers = sort {$a <=> $b} keys %messages;
    my $max = pop [sort {$a <=> $b} map {length $_} @message_numbers];
    my @menu;
    push @menu, sprintf "%*s : %s", $max, $_, $messages{$_}{msg}[0] for @message_numbers;
    my ($choice) = Menu::simple('pick a message> ', @menu);
    return -1 == $choice ? () : (%{$messages{$message_numbers[$choice]}});
}
#ZZZ

# #AAA process_family 
sub process_family {
    my %input = %{shift @_};
    my $solver = shift;
    my %msg = get_msg(\%input);
    while (1) {
        last unless exists $msg{msg};
        while (1) {
            &$solver(%msg);
            print 'do something> ';
            chomp(my $input=<STDIN>);
            last if $input eq 'quit';
        }
        %msg = get_msg(\%input);
    }
}
#ZZZ

# read in msgs file
my $input_file = shift;
my %msgs = %{$jpp_in->decode(join(' ',path($input_file)->lines({chomp=>1})))};

while (1) {
    my ($solver, %family) = get_family(\%msgs);
    process_family(\%family, $solver);
    my ($rinse) = Menu::simple('continue? ', 'no', 'yes');
    (1 == $rinse) ? next : last;
}
# we can add code here to save work.  temp file or live data?
