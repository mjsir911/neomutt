#!/usr/bin/perl -w

use YAML;
use strict;
use warnings;

my @MAP;

my $xml = shift @ARGV;

while (<>) {
	if (/"options:\\n"/) {
		read_n_parse_options()
	}
}

sub read_n_parse_options {
	while (my $out = <>) {
		my ($opt, $arg, $text) = $out =~ /^\s+"\s+(?:((?:\s?(?:-[\w\d-]+))+)\s?(?:<(\w+)>)?\s*)?(.+?)(?:\\n)?"/;

		my $index = defined $MAP[0] ? @MAP : 0;
		if (defined $opt) {
			%{ $MAP[$index] } =  (opt => $opt, arg => $arg, desc => $text);
		} else {
			$MAP[$index - 1]{desc} .= " ";
			$MAP[$index - 1]{desc} .= $text;
		}

		if ($out =~ /\)\)\;/) {
			last;
		}
	}
}

print Dump(\@MAP);
