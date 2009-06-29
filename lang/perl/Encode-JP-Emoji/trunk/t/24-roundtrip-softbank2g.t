use strict;
use warnings;
use lib 't';
require 'test-util.pl';
use Test::More;
use Encode;
use Encode::JP::Emoji;

my $encode1 = 'x-sjis-emoji-softbank2g-pp';
my $encode2 = 'x-sjis-e4u-softbank2g-pp';
my $encode3 = 'x-utf8-e4u-softbank2g-pp';
my $table = read_tsv('t/softbank-table.tsv');
my @keys = sort {$a cmp $b} keys %$table;

plan tests => 6 * @keys;

foreach my $sjisH (@keys) {
	my $utf8H = $table->{$sjisH};

    my $strS  = chr hex $utf8H;				# SoftBank UTF-8 string
    my $octA  = encode($encode1, $strS);	# SoftBank CP932 octets escaped
	my $strB  = decode($encode2, $octA);	# Google UTF-8   string
	my $octC  = encode($encode3, $strB);	# SoftBank UTF-8 octets escaped

    my $octS  = encode utf8 => $strS;		# SoftBank UTF-8 octets
	my $strD  = decode($encode3, $octS);	# Google UTF-8	 string
	my $octE  = encode($encode2, $strD);	# SoftBank CP932 octets escaped
	my $strF  = decode($encode1, $octE);	# SoftBank UTF-8 string

	like($octA, qr/^\x1B\x24([GEFOPQ])([\x20-\x7F]+)\x0F$/, "$utf8H escape $encode1");
	like($octE, qr/^\x1B\x24([GEFOPQ])([\x20-\x7F]+)\x0F$/, "$utf8H escape $encode2");
	like($octC, qr/^\x1B\x24([GEFOPQ])([\x20-\x7F]+)\x0F$/, "$utf8H escape $encode3");

	is(shex($strF), shex($strS), "$utf8H SoftBank UTF-8 string");
	is(ohex($octE), ohex($octA), "$utf8H SoftBank CP932 octets");
	is(shex($strB), shex($strD), "$utf8H Google   UTF-8 string");
#	is(ohex($octC), ohex($octS), "$utf8H SoftBank UTF-8 octets");	# not same
}
