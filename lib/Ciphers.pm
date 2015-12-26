package Ciphers;

use strict;
use warnings;
use v5.18;

use Data::Printer;
use Path::Tiny;
use JSON::PP;

use Stats;

# parse_action #AAA
sub parse_action {
    my ($action, $show_stats, $stat_order, $solved, $href) = @_;
    my $my_action   = 1 - ($action =~ s/quit//);
    if ($action =~ s/(number|alpha)//) {
	$stat_order = $1;
    }
    if ($action =~ s/solved//) {
	$solved = 1;
	$my_action = 0; 
    }
    if ($action =~ s/stats//) {
	$show_stats = 1 - $show_stats;
    }
    $action =~ s/^\s+|\s+$//g; # remove leading/trailing spaces
    if ($action) {
	for (split /:/, $action) {
	    next unless length $_ le 2;
	    my ($f, $s) = split //, uc $_;
	    $href->{$f} = $s =~ /\w/ ? $s : ' ';
	}
    }
    return ($my_action, $show_stats, $stat_order, $solved, $href);
}
#ZZZ

# aristocrat_decrypt #AAA
sub aristocrat_decrypt {
#   p @_;
    my %data = %{shift @_};
    my $CIPHER = join('', keys $data{state})//'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    my $plain = lc join('', values $data{state})//'abcdefghijklmnopqrstuvwxyz';

    my @rtn;
    for (@{$data{msg}}) {
	my $line = $_;
	eval "\$line =~ tr/$CIPHER/$plain/" if $CIPHER;
	$line =~ s/[[:upper:]]/ /g;
	eval "\$line =~ tr/$plain/\U$plain/" if $plain;
	push @rtn, $line;
    }
    return wantarray ? @rtn : \@rtn;
}
#ZZZ

# aristocrat #AAA
sub aristocrat_solver {
    my %data = %{shift @_};
    $data{state} = {} unless defined $data{state};
    $data{stats} = {Stats::mono_stats($data{msg})} unless defined $data{stats};

    my $stat_order = 'alpha';
    my $show_stats = 1;
    my $action = 1;
    while ($action and ! $data{solved}) {
	system('clear');
	my @stats = Stats::show_mono_stats($data{stats}, $stat_order);
	say $stats[0] if $show_stats;
	say $stats[-1];
	say for aristocrat_decrypt({state=>$data{state}, msg=>[$stats[-1]]}); # create a fake message to decrypt
	say '';
	my @decrypt = aristocrat_decrypt(\%data);
	for (keys @{$data{msg}}) {
	    say $data{msg}[$_];
	    say $decrypt[$_];
	    say '';
	}
        print "cipher/plain pair? ";
        chomp($action=<STDIN>);
	($action, $show_stats, $stat_order, $data{solved}, $data{state}) = parse_action($action, $show_stats, $stat_order, $data{solved}, $data{state}); # we overwrite action, stat_key and data{state} based on action
    }
    return wantarray ? %data : \%data;
}
#ZZZ

1;
