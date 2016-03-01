package Ciphers::Mono;

use strict;
use warnings;
use v5.18;
use experimental qw(smartmatch);

use Data::Printer;

#use Path::Tiny;
#use JSON::PP;

#use Setup;
#our %config;
#our %config = Setup::init_Config() unless keys %config; #this should be the instantiation
#$config{setup} = 'Ciphers::Mono';
#our %config;
#warn 'showing config frm Ciphers::Mono';
#p %config;

#use Menu;
#use Stats;

# commands AAA

my %commands;
%commands = (

# order AAA
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

# rev AAA
    rev => sub {
	my %in = %{shift @_};
	$in{top} = [reverse @{$in{top}}];
	$in{bottom} = [reverse @{$in{bottom}}];
	return wantarray ? %in : \%in;
    },
#ZZZ

# slide AAA
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

# insert AAA
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

# keywords AAA
    keyword => sub {
	my %in = %{shift @_};
	push @{$in{keywords}}, uc $in{option};
	return wantarray ? %in : \%in;
    },
#ZZZ

);
#ZZZ

# delete this later #AAA
#
## monoalphabetic_key_recovery AAA
#sub monoalphabetic_key_recovery {
#    my %msg = %{shift @_};
#    my %bob = $commands{order}({option => 'key', key => $msg{state}, val => {reverse %{$msg{state}}}});
#
#    my $commands_regex = join('|', map {"($_)"} ('quit', keys %commands));
#    $commands_regex = qr/$commands_regex/;
#    while (1) {
#  	system('clear');
#	say "order = $bob{order}";
#	say join(' ', 'key :', @{$bob{top}});
#	say join(' ', 'val :', @{$bob{bottom}});
#	if (exists $bob{keywords}) {
#	    say 'keywords :';
#	    say "\t$_" for @{$bob{keywords}};
#	}
#	print "command? ";
#	chomp(my $reply = <STDIN>);
#	$reply =~ s/\b($commands_regex)\b//;
#	my $cmd = $1;
#	last if $cmd eq 'quit';
#	next unless exists $commands{$cmd};
#	$bob{option} = $reply =~ s/^\s*|\s*$//r;
#	%bob = $commands{$cmd}(\%bob);
#    }
#    print "update? ";
#    chomp(my $reply = <STDIN>);
#    $bob{update} = $reply =~ /^y/i;
#    if ($bob{update} and exists $bob{keywords}) {
#	$msg{keywords} = [@{$bob{keywords}}];
#	$msg{update} = 1;
#    }
#    return wantarray ? %msg : \%msg;
#}
##ZZZ
#
## monosubstitution AAA
#sub monosubstitution {
#    my %data = %{shift @_};
#    my $CIPHER = join('', keys $data{state})//'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
#    my $plain = lc join('', values $data{state})//'abcdefghijklmnopqrstuvwxyz';
#
#    my @rtn;
#    for (@{$data{msg}}) {
#	my $line = $_;
#	eval "\$line =~ tr/$CIPHER/$plain/" if $CIPHER;
#	$line =~ s/[[:upper:]]/ /g;
#	eval "\$line =~ tr/$plain/\U$plain/" if $plain;
#	push @rtn, $line;
#    }
#    return wantarray ? @rtn : \@rtn;
#}
##ZZZ
#
## parse_action AAA
#sub parse_action {
#    my %checks = %{shift @_};
#    my $my_action   = 1 - ($checks{action} =~ s/quit//);
#    if ($checks{action} =~ s/(number|alpha)//) {
#	$checks{stat_order} = $1;
#    }
#    if ($checks{action} =~ s/solved//) {
#	$checks{solved} = 1;
#	$my_action = 0; 
#    }
#    if ($checks{action} =~ s/stats//) {
#	$checks{show_stats} = 1 - $checks{show_stats};
#    }
#    if ($checks{action} =~ s/flip//) {
#	$checks{flip} = 1 - $checks{flip};
#    }
#    $checks{action} =~ s/^\s+|\s+$//g; # remove leading/trailing spaces
#    if ($checks{action}) {
#	for (split /:/, $checks{action}) {
#	    next unless length $_ le 2;
#	    my ($f, $s) = split //, uc $_;
#	    $checks{state}{$f} = $s =~ /\w/ ? $s : ' ';
#	}
#    }
#    $checks{action} = $my_action;
#    return wantarray ? %checks : \%checks;
#}
##ZZZ
#
## _monoalphabetic_display_text AAA
#sub _monoalphabetic_display_text {
#    my $flip = shift;
#    my @top; my @bot;
#    if ($flip) {
#	@bot = @{shift @_};
#	@top = @{shift @_};
#    } else {
#	@top = @{shift @_};
#	@bot = @{shift @_};
#    }
#    while (my ($ndx, $top) = each @top) {
#	say $top;
#	say $bot[$ndx];
#	say '';
#    }
#}
##ZZZ
#
## _monoalphabetic_display AAA
#sub _monoalphabetic_display {
#    my %config      = %{shift @_};
#    my %stats       = %{shift @_};
#    my @msg_encrypt = @{shift @_};
#    my @msg_decrypt = monosubstitution({state=>$config{state}, msg=>[@msg_encrypt]});
#
#    say join(' ', @{$stats{$config{stat_order}}{vals}}) if $config{show_stats};
#    my $fake_msg_encrypt = join(' ',@{$stats{$config{stat_order}}{keys}}); # fake_msg are the keys to stats
#    my $fake_msg_decrypt = join(' ',monosubstitution({state=>$config{state}, msg=>[$fake_msg_encrypt]})); # decrypt the generated fake message
#    _monoalphabetic_display_text($config{flip}, [$fake_msg_encrypt], [$fake_msg_decrypt]);
#    say '';
#    _monoalphabetic_display_text($config{flip}, \@msg_encrypt, \@msg_decrypt)
#}
##ZZZ
#
## monoalphabetic_plaintext_recovery AAA
#sub monoalphabetic_plaintext_recovery {
#    my %msg = @_;
#    $msg{update} = 0;
#    my %bob = (stat_order=>'alpha', show_stats=>1, action=>1, flip=>0, solved=>$msg{solved});
#    $bob{state} = defined $msg{state} ? $msg{state} : {};
#    my @msg_encrypt = @{$msg{msg}}; #$bob{msg} = $msg{msg};
#    my %stats = Stats::build_stat_indices($msg{stats}//{});
#
#    while ($bob{action} and ! $bob{solved}) {
#	system('clear');
#	_monoalphabetic_display(\%bob, \%stats, \@msg_encrypt);
#	print "encrypt/decrypt pair? ";
#	chomp($bob{action}=<STDIN>);
#	%bob = parse_action(\%bob);
#    }
#    $bob{action} = 'yes';
#    if (! $bob{solved}) {
#	print "save msg? ";
#	chomp($bob{action}=<STDIN>);
#    }
#    if ($bob{action} =~ /^y/i) {
#	$msg{solved} = $bob{solved};
#	$msg{state} = $bob{state};
#	$msg{update} = 1;
#    }
#    return wantarray ? %msg : \%msg;
#}
##ZZZ
#
## monoalphabetic_solver AAA
#sub monoalphabetic_solver {
#    my %msg = @_;
#
#    $msg{stats} = {Stats::mono_stats($msg{msg})} unless exists $msg{stats};
#
#    while (1) {
#	my @work_menu = qw/plaintext key/;
#	#my ($work) = Menu::pick({header=>'which would you like to recover? '}, @work_menu);
#	my $work = Menu::simple('which would you like to recover? ', @work_menu);
#	last if $work < 0;
#	my %update = $work ? monoalphabetic_key_recovery(%msg) : monoalphabetic_plaintext_recovery(%msg);
#	if ($update{update}) {
#	    delete $update{update};
#	    %msg = %update;
#	}
#    }
#    return wantarray ? %msg : \%msg;
#}
##ZZZ
#ZZZ

# new_mono_sub AAA
sub new_mono_sub {
    our %config;
    if ($_[0] eq 'debug') {
	shift;
	p @_;
	say join(' : ', (caller(0))[0,1,2,3]);
    }
#   my %config = %{shift @_};
#   my %msg = %{shift @_};
    my %msg = (@_);
    my $encrypt = join('', keys $msg{state})//'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    my $decrypt = lc join('', values $msg{state})//'abcdefghijklmnopqrstuvwxyz';

    my @rtn;
    for (@{$msg{msg}}) {
	my $line = $_;
	eval "\$line =~ tr/$encrypt/$decrypt/";
	$line =~ s/[[:upper:]]/ /g;
	eval "\$line =~ tr/$decrypt/\U$decrypt/";
	push @rtn, $line;
    }
    return wantarray ? @rtn : \@rtn;
}
#ZZZ

# mono_Message_display #AAA
sub mono_Message_display {
    our %config;
    if ($_[0] eq 'debug') {
	shift;
	warn 'mono_Message_display has config as';
	p %config;
	say join(' : ', (caller(0))[0,1,2,3]);
    }
    my %msg = %{shift @_};
    #my @decrypt = new_mono_sub(@_);
    my @decrypt = new_mono_sub(%msg);

#   my %config = %{shift @_};
#   my %msg = %{shift @_};
    my @top    = $config{top_line} eq 'decrypt' ? @decrypt     : @{$msg{msg}};
    my @bottom = $config{top_line} eq 'decrypt' ? @{$msg{msg}} : @decrypt;
    while (my ($ndx, $val) = each (@top)) {
	say $val;
 	say $bottom[$ndx];
	say '';
    }
    say '';
}
#ZZZ

# mono_Stat_display #AAA
sub mono_Stat_display {
    our %config;
    if ($_[0] eq 'debug') {
	shift;
	warn 'mono_Stat_display has config as:';
	p %config;;
	say join(' : ', (caller(0))[0,1,2,3]);
    }
#   p %config;
    #warn 'input for mono_Stat_display';
    #p @_;
    my %msg = %{shift @_};
    #p %msg;
    #die 'Stat_display check';
    my @order = Stats::get_Stat_order($msg{stats});
    if ($config{show_stat} eq 'yes') {
	say join(' ', map {sprintf "%2s", $_} @{$msg{stats}{freqs}}{@order});
	say join(' ', map {sprintf "%2s", $_} @order);
	say '';
    }
}
#ZZZ

# mono_Recovery_display #AAA
sub mono_Recovery_display {
    our %config;
    if ($_[0] eq 'debug') {
	shift;
	warn 'mono_Recovery_display has config as:';
	p %config;
	say join(' : ', (caller(0))[0,1,2,3]);
    }

#   p %config;
    my %msg = %{shift @_};
#   p %msg;
    my @order = Stats::get_Stat_order($msg{stats});
    my @top    = $config{top_line} eq 'decrypt' ? @{$msg{state}}{@order} : @order;
    my @bottom = $config{top_line} eq 'decrypt' ? @order : @{$msg{state}}{@order};
    say join(' ', map {sprintf "%2s", $_} @top);
    say join(' ', map {sprintf "%2s", $_} @bottom);
    say '';
}
#ZZZ

# config_merge #AAA
sub config_merge {
    our %parse_rules;
    my %rules = %{$parse_rules{configs}};
    our %config;
    my @list = (@_);
#   my %config = %{shift @_};
#   my @list = @{shift @_};
    for my $tag (@list) {
        my $key = $rules{$tag}{display};
        if ($rules{$tag}{type} eq 'toggle') {
            ($config{$key}) = grep {$_ ne $config{$key}} @{$rules{$tag}{values}};
        } else {
            my @menu = @{$rules{$tag}{values}};
            my @items = Menu::pick(@menu);
        }
    }
    return %config;
}
#ZZZ

# cipher_Plain_merge #AAA
sub _cipher_Plain_merge {
    my %rtn = %{shift @_};
    for (map {split /:/} @{shift @_}) {
        my ($c, $p) = split //, uc $_;
        $rtn{$c} = $p;
    }
    return wantarray ? %rtn : \%rtn;
}
#ZZZ

## parser #AAA
#sub parser {
#    our %rules;
#    p %rules;
#    die 'parser';
#    my @parts = @_;
#    my %rtn;
#    for my $type (keys %rules) {
#        if (ref $rules{$type}) {
#            push @{$rtn{$type}}, grep {$_ ~~ $rules{$type}} @parts;
#        } else {
#            push @{$rtn{$type}}, grep {$_ =~ qr/$rules{$type}/} @parts;
#        }
#        @parts = grep {! ($_ ~~ $rtn{$type})} @parts;
#    }
#    @{$rtn{unknown}} = @parts;
#    return %rtn;
#}
##ZZZ


our %callbacks = (
    msg => \&mono_Message_display,
    stats => \&mono_Stat_display,
    recovery => \&mono_Recovery_display,
);

# this may need some tlc
## local_display #AAA
#sub local_display {
#    our %config;
##   p @_;
##    my %input = %{shift @_};
##    p %input;
##   die 'check';
#    system('clear'); # here there be dragons
#    my %cb = %Ciphers::Mono::callbacks;
#    &{$cb{$_}}(@_) for split /\s/, $config{display}; # should we just mae config{display} a list?
##   &{$callbacks{stats}}(@_);
##   &{$cb{recovery}}(@_);
##   &{$cb{msg}}(@_);
#}
##ZZZ

# mono #AAA
sub mono {
    our %config;
    my %msg = (@_);
    $msg{stats} = {Stats::mono_Stats($msg{msg})} unless exists $msg{stats};
#   p %msg;
#   die 'after mono_Stats';
my %current_parse = ( 'quit' => 1 );
    if (! exists $msg{state} or ! defined $msg{state}) {
	$msg{state} = {map {$_ => ' '} keys %{$msg{stats}{freqs}}};
    }

    {
	local_display(\%msg);
	print '> ';
	chomp(my $response=<STDIN>);
	my %response_parsed = parser($response);
	p %response_parsed;
	die 'response checke';
	%config = config_merge(current=>\%config, update=>$response_parsed{configs}) if exists $response_parsed{configs};
	$msg{state} = _cipher_Plain_merge($msg{state}, $response_parsed{cp}) if exists $response_parsed{cp};
	'quit' ~~ $current_parse{actions} ? last : redo;
    }
}
#ZZZ

# next task !!!!!!!!!!!!!!#AAA
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
#ZZZ

1;
