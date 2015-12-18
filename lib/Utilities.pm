package Utilities;

use strict;
use warnings;
use v5.18;
use Data::Printer;
use Path::Tiny;
use JSON::PP;

my $nl = "\n";

# Dedupe AAA
sub Dedupe {
    my @list = split //, shift;
    my @short_list;
    for my $a (@list) {
	(grep {/$a/} @short_list) ? next : push(@short_list,$a);
    }
    return join('',@short_list);
}
# ZZZ

# Numberfy AAA
sub Numberfy {
    my $word = shift;
    my $count = 0;
    my @list;
    push @list, map {sprintf "%s%02d", $_, $count++} split //, $word;	
    $count = 0;
    my %hash = map {$_=>$count++} sort @list;
    my @rtn = map {1+$_} @hash{@list};
    return wantarray ? @rtn : \@rtn;
}
#ZZZ

# Decimate AAA
sub Decimate {
    my @chars = split //, shift;
    my $op = shift;
    my $width;
    my @order;
    if ($op =~ /\d/) {
	$width = $op;
	@order = (0..$op-1);
    } else {
	$width = length $op;
	my $count = 0;
	my %hash = map {$count++=>$_} Numberfy($op);
	%hash = reverse %hash;
	@order = @hash{sort {$a<=>$b} keys %hash};
    }
    my @rtn = (('')x$width);
    my $pos = 0;
    my $index = $pos;
    while (grep {/\w/} @chars) {
	$rtn[$index] .= $chars[$pos];
	$chars[$pos] = ' ';
    } continue {
	$pos += $width;
	if ($pos >= @chars) {
	    $index = $pos %= @chars;
	}
	if ($pos < @chars and $chars[$pos] eq ' ') {
	    $pos++;
	    $index = $pos %= @chars;
	}
    }
    @rtn = @rtn[@order];
    return wantarray ? @rtn : \@rtn;
}
#ZZZ

# On_width AAA
sub On_width {
    my $str = shift;
    my $width = shift;
    $width = length $width unless $width =~ /\d/;
    my @rows = split /\s/, $str =~ s/(.{$width})/$1 /gr;
    return wantarray ? @rows : \@rows;
}
#ZZZ

sub Aca_password {
    my $jpp_in = JSON::PP->new->utf8;
    my %msgs = %{$jpp_in->decode(join(' ',path(shift)->lines({chomp=>1})))};
    my $str = lc substr($msgs{A}{1}{msg}[0] =~ s/\W//gr,0,7).'1';
    return $str;
}


1;
