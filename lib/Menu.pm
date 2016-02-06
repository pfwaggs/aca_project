package Menu;

use Data::Printer;
use strict;
use warnings;
use v5.18;
use experimental qw(smartmatch autoderef);

# ary_To_hash #AAA
sub ary_To_hash {
    my %rtn;
    while (my ($ndx, $val) = each (@_)) {
	$rtn{1+$ndx} = $val;
    }
    return %rtn;
}
#ZZZ

# max_Length_hash_Keys #AAA
sub max_Length_hash_Keys {
    my %data = %{shift @_};
    return pop [sort {$a <=> $b} map {length $_} keys %data];
}
#ZZZ

# hash2 #AAA
sub hash2 {
    my %in_hash = %{shift @_};
    my %key_hash;
    my $ndx = 1;
    while (my ($key, $val) = each (%in_hash)) {
	$key_hash{$ndx++} = $key;
    }
    return %key_hash;
}
#ZZZ

# simple AAA
sub simple2 {
    my %input = (@_);
    my %data = %{$input{data}};
    my %key_hash = hash2(\%data);

    my $default = $input{default}//undef;
    my $prompt = ($default ~~ %data) ? "pick (default:=$data{$default})> " : 'pick >';

    my $width = 1 + int log(keys %key_hash)/log(10);
    my @sorted_key_hash = sort {$a <=> $b} keys %key_hash;
    my @menu = map {sprintf "%*s : %s", $width, $_, $data{$key_hash{$_}}} @sorted_key_hash;
    my $rtn;
    {
	system('clear');
	say for @menu;
	print $prompt;
	chomp($rtn=<STDIN>);
	last if $rtn =~ /^\s*$/;
	redo if $rtn =~ /\D/;
	($rtn//$default ~~ @sorted_key_hash) ? last : redo;
    }
    return ($rtn//$default ~~ @sorted_key_hash ? $key_hash{$rtn} : $default);
}
#ZZZ


sub simple {
    my %input = (@_);
    my @data = @{$input{data}};
    my @keys = (0..@data-1);
    my $default = $input{default}//0;
    my $prompt = $input{prompt}//($default-1 ~~ [keys @data] ? "pick (default:=$data[$default-1])> " : 'pick > ');
    my $width = 1 + int log(@data)/log(10);
    my @menu = map {sprintf "%*s : %s", $width, 1+$_, $data[$_]} keys @data; # visually increment index
    say STDERR for @menu;
    my $rtn;
    {
	print STDERR $prompt;
	chomp($rtn=<STDIN>);
	last if $rtn =~ /^\s*$/;
	($rtn-1 ~~ [keys @data]) ? last : redo;
    }
    return ($rtn =~ /\d/ ? $rtn : $default) - 1 # correct the index value
}


# complex #AAA
sub complex {
    my %input = (@_);
    my %defaults = (
	header       => undef,
	prompt       => 'pick lines: ',
	clear_screen => 1,
	max_return   => 1,
	presets      => [],
	yes          => '*',
	no           => ' ',
    );
    my %config = (%defaults, exists $input{config} ? %{$input{config}} : ());
    my @keys = @{$input{keys}};
    my %data = %{$input{data}};
    my $toggle = $config{yes}^$config{no};
    my $max_return = $config{max_return}//@keys;

    my ($max_width) = sort {$b <=> $a} map {length $_} @keys;
    my %_menu = map {$_ => { key=>sprintf("%*s",$max_width,$_), str=>$data{$_}, s=>$config{no}}} @keys;
    my $seq = 1;
    for (@{$config{presets}}) {
	$_menu{$_}{s} ^= $toggle;
	$_menu{$_}{order} = $seq++;
    }

    {
	my @choices;
	system('clear') if $config{clear_screen};
	say $config{header} if defined $config{header};
	say join(' : ', @{$_menu{$_}}{qw{key s str}}) for @keys;
	print $config{prompt};
	chomp(@choices = grep {$_ ~~ ['all', @keys]} split /\s+/, <STDIN>);
	if (exists $config{presets} and @choices) {
	    for (@{$config{presets}}) {
		$_menu{$_}{s} ^= $toggle;
		delete $_menu{$_}{order};
	    }
	    $seq = 1;
	    $config{presets} = ();
	} else {
	    last if ($max_return <= grep {$_menu{$_}{s} eq $config{yes}} keys %_menu) and ! ('all' ~~ @choices);
	    redo unless @choices;
	}
	for ('all' ~~ @choices ? @keys : @choices) {
	    $_menu{$_}{s} ^= $toggle;
	    $_menu{$_}{order} = $seq++;
	}
	(($max_return <= grep {$_menu{$_}{s} eq $config{yes}} keys %_menu) and ! ('all' ~~ @choices)) ? last : redo;
    }
    my @found = sort {$_menu{$b}{order} <=> $_menu{$a}{order}} grep {$_menu{$_}{s} eq $config{yes}} @keys;
    my @rtn = @found <= $max_return ? @found : @found[0..$max_return-1];
    return reverse @rtn;
}
#ZZZ

1;
