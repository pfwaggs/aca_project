package Ciphers;

use strict;
use warnings;
use v5.18;

use Data::Printer;
#use Path::Tiny;
#use JSON::PP;

use Stats;

# parse_action #AAA
sub parse_action {
    my %checks = %{shift @_};
    my $my_action   = 1 - ($checks{action} =~ s/quit//);
    if ($checks{action} =~ s/(number|alpha)//) {
	$checks{stat_order} = $1;
    }
    if ($checks{action} =~ s/solved//) {
	$checks{solved} = 1;
	$my_action = 0; 
    }
    if ($checks{action} =~ s/stats//) {
	$checks{show_stats} = 1 - $checks{show_stats};
    }
    $checks{action} =~ s/^\s+|\s+$//g; # remove leading/trailing spaces
    if ($checks{action}) {
	for (split /:/, $checks{action}) {
	    next unless length $_ le 2;
	    my ($f, $s) = split //, uc $_;
	    $checks{state}{$f} = $s =~ /\w/ ? $s : ' ';
	}
    }
    $checks{action} = $my_action;
    return wantarray ? %checks : \%checks;
}
#ZZZ

# monosubstitution #AAA
sub monosubstitution {
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

sub aristocrat_key_analysis {
    ...;
}

# aristocrat_plaintext #AAA
sub aristocrat_plaintext {
    my %msg = %{shift @_};
    $msg{update} = 0;
    my %bob = (stat_order=>'alpha', show_stats=>1, action=>1, solved=>$msg{solved});
    $bob{state} = defined $msg{state} ? $msg{state} : {};
    my @cipher_msg = @{$msg{msg}}; #$bob{msg} = $msg{msg};
    my %stats = Stats::build_stat_indices($msg{stats});

    while ($bob{action} and ! $bob{solved}) {
	system('clear');
	say join(' ', @{$stats{$bob{stat_order}}{vals}}) if $bob{show_stats};
	say my $fake = join(' ', @{$stats{$bob{stat_order}}{keys}});
	say for monosubstitution({state=>$bob{state}, msg=>[$fake]}); # pass the generated fake message to decrypt
	say '';
	my @decrypt = monosubstitution({state=>$bob{state}, msg=>[@cipher_msg]});
	while (my ($ndx, $cipher) = each @cipher_msg) {
	    say $cipher;
	    say $decrypt[$ndx];
	    say '';
	}
	print "cipher/plain pair? ";
	chomp($bob{action}=<STDIN>);
	%bob = parse_action(\%bob);
    }
    $bob{action} = 'yes';
    if (! $bob{solved}) {
	print "save msg? ";
	chomp($bob{action}=<STDIN>);
    }
    if ($bob{action} =~ /^y/i) {
	$msg{solved} = $bob{solved};
	$msg{state} = $bob{state};
	$msg{update} = 1;
    }
    return wantarray ? %msg : \%msg;
}
#ZZZ

# aristocrat_solver #AAA
sub aristocrat_solver {
    my %msgs = %{shift @_};

    my @msgs_list = sort {$a<=>$b} keys %msgs;
    my @menu = map {$msgs{$_}{msg}[0]} @msgs_list;
    while (1) {
	my ($msg) = Menu::Pick({header=>'pick a message'}, @menu);
	$msg = $msgs_list[$msg]; # remap the return to a msgs hash key value

	my @work = ('plaintext recovery', 'key analysis');
	my ($work) = Menu::Pick({header=>'which would you like to do? '}, @work);
	my %update = $work ? aristocrat_key_analysis($msgs{$msg}) : aristocrat_plaintext($msgs{$msg});
	if ($update{update}) {
	    delete $update{update};
	    $msgs{$msg} = %update;
	}
    }
    return wantarray ? %msgs : \%msgs;
}
#ZZZ

sub headline_display {
    my %data = %{shift @_};
    p %data;
    for (sort keys %data) {
	say join(' : ', $_, @{$data{$_}{msg}});
    }
}

sub headline_solver {
    my %data = %{shift @_};
    headline_display(\%data);
}

1;
