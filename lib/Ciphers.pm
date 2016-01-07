package Ciphers;

use strict;
use warnings;
use v5.18;

use Data::Printer;
#use Path::Tiny;
#use JSON::PP;

use Stats;
use Menu;

#AAA parse_action 
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
    if ($checks{action} =~ s/flip//) {
	$checks{flip} = 1 - $checks{flip};
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

#AAA monosubstitution 
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

#AAA commands 

my %commands;
%commands = (

#AAA order 
    order => sub {
	my %in = %{shift @_};
	$in{order} = $in{option};
	my %t = $in{order} eq 'key' ? %{$in{key}} : %{$in{val}};
	my @a = sort keys %t;
	my @b = @t{@a};
	@in{qw/top bottom/} = $in{order} eq 'key' ? ([@a], [@b]) : ([@b], [@a]);
	return wantarray ? %in : \%in;
    },
#ZZZ

#AAA rev 
    rev => sub {
	my %in = %{shift @_};
	$in{top} = [reverse @{$in{top}}];
	$in{bottom} = [reverse @{$in{bottom}}];
	return wantarray ? %in : \%in;
    },
#ZZZ

#AAA slide 
    slide => sub {
	my %in = %{shift @_};
	my %t = $in{order} eq 'key' ? %{$in{key}} : %{$in{val}};
	my @a = sort keys %t;
	my @b = @t{@a};
	while ($b[0] ne uc $in{option}) { # a little tricky here; a is the sorted list so b probably has the keyword
	    push @a, $a[0]; shift @a;
	    push @b, $b[0]; shift @b;
	}
	@in{qw/top bottom/} = $in{order} eq 'key' ? ([@a], [@b]) : ([@b], [@a]);
	return wantarray ? %in : \%in;
    },
#ZZZ

#AAA insert 
    insert => sub {
	my %in = %{shift @_};
	for (split /:/, uc $in{option} =~ s/^\s*|\s*$//gr) {
	    my ($key, $val) = split //, $_, 2;
	    $in{key}{$key} = $val;
	    $in{val}{$val} = $key;
	}
	$in{option} = $in{order};
	%in = $commands{order}(\%in);
	return wantarray ? %in : \%in;
    },
#ZZZ

#AAA keywords 
    keyword => sub {
	my %in = %{shift @_};
	push @{$in{keywords}}, uc $in{option};
	return wantarray ? %in : \%in;
    },
#ZZZ

);
#ZZZ

#AAA aristocrat_key_recovery 
sub aristocrat_key_recovery {
    my %msg = %{shift @_};
    my %bob = $commands{order}({option => 'key', key => $msg{state}, val => {reverse %{$msg{state}}}});

    my $commands_regex = join('|', map {"($_)"} ('quit', keys %commands));
    $commands_regex = qr/$commands_regex/;
    while (1) {
  	system('clear');
	say "order = $bob{order}";
	say join(' ', 'key :', @{$bob{top}});
	say join(' ', 'val :', @{$bob{bottom}});
	if (exists $bob{keywords}) {
	    say 'keywords :';
	    say "\t$_" for @{$bob{keywords}};
	}
	print "command? ";
	chomp(my $reply = <STDIN>);
	$reply =~ s/\b($commands_regex)\b//;
	my $cmd = $1;
	last if $cmd eq 'quit';
	next unless exists $commands{$cmd};
	$bob{option} = $reply =~ s/^\s*|\s*$//r;
	%bob = $commands{$cmd}(\%bob);
    }
    print "update? ";
    chomp(my $reply = <STDIN>);
    $bob{update} = $reply =~ /^y/i;
    if ($bob{update} and exists $bob{keywords}) {
	$msg{keywords} = [@{$bob{keywords}}];
	$msg{update} = 1;
    }
    return wantarray ? %msg : \%msg;
}
#ZZZ

#AAA _aristocrat_display_text 
sub _aristocrat_display_text {
    my $flip = shift;
    my @top; my @bot;
    if ($flip) {
	@bot = @{shift @_};
	@top = @{shift @_};
    } else {
	@top = @{shift @_};
	@bot = @{shift @_};
    }
    while (my ($ndx, $top) = each @top) {
	say $top;
	say $bot[$ndx];
	say '';
    }
}
#ZZZ

#AAA _aristocrat_display 
sub _aristocrat_display {
    my %config      = %{shift @_};
    my %stats       = %{shift @_};
    my @msg_encrypt = @{shift @_};
    my @msg_decrypt = monosubstitution({state=>$config{state}, msg=>[@msg_encrypt]});

    say join(' ', @{$stats{$config{stat_order}}{vals}}) if $config{show_stats};
    my $fake_msg_encrypt = join(' ',@{$stats{$config{stat_order}}{keys}}); # fake_msg are the keys to stats
    my $fake_msg_decrypt = join(' ',monosubstitution({state=>$config{state}, msg=>[$fake_msg_encrypt]})); # decrypt the generated fake message
    _aristocrat_display_text($config{flip}, [$fake_msg_encrypt], [$fake_msg_decrypt]);
    say '';
    _aristocrat_display_text($config{flip}, \@msg_encrypt, \@msg_decrypt)
}
#ZZZ

#AAA aristocrat_plaintext_recovery 
sub aristocrat_plaintext_recovery {
    my %msg = %{shift @_};
    $msg{update} = 0;
    my %bob = (stat_order=>'alpha', show_stats=>1, action=>1, flip=>0, solved=>$msg{solved});
    $bob{state} = defined $msg{state} ? $msg{state} : {};
    my @msg_encrypt = @{$msg{msg}}; #$bob{msg} = $msg{msg};
    my %stats = Stats::build_stat_indices($msg{stats}//{});

    while ($bob{action} and ! $bob{solved}) {
	system('clear');
	_aristocrat_display(\%bob, \%stats, \@msg_encrypt);
	print "encrypt/plain pair? ";
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

#AAA aristocrat_solver 
sub aristocrat_solver {
    my %msgs = %{shift @_};

    my %msg_menu = map {$_=>$msgs{$_}{msg}[0]} keys %msgs;
    my @msgs_list = sort {$a<=>$b} keys %msg_menu;
    while (1) {
	my ($msg) = Menu::pick({header=>'pick a message'}, {%msg_menu, keys=>\@msgs_list});
	last unless $msg;
	$msgs{$msg}{stats} = {Stats::mono_stats($msgs{$msg}{msg})} unless exists $msgs{$msg}{stats};

	while (1) {
	    my %work_menu = (1=>'key recovery', 2=>'plaintext recovery');
	    my $work_menu_keys = [1,2];
	    my ($work) = Menu::pick({header=>'which would you like to do? '}, {%work_menu, keys=>$work_menu_keys});
	    last unless $work;
	    my %update = $work ? aristocrat_plaintext_recovery($msgs{$msg}) : aristocrat_key_recovery($msgs{$msg});
	    if ($update{update}) {
		delete $update{update};
		$msgs{$msg} = {%update};
	    }
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
