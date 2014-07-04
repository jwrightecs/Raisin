
use strict;
use warnings;

use FindBin '$Bin';
use Test::More;

use lib "$Bin/../../lib";

use Raisin::Param;
use Types::Standard qw(ScalarRef Any Num Str Int);

my @types = (
    optional => ['str', Str, undef, qr/regex/],
    required => ['float', Num, 0, qr/^\d\.\d+$/],
    requires => ['int', Int],
);
my @values = (
    [qw(invalid regex)],
    [12, '1.2000'],
    [qw(digit 123)]
);
my @keys = qw(named params);

my $index = 0;
while (my @param = splice @types, 0, 2) {
    my $required = $param[0] =~ /require(?:d|s)/ ? 1 : 0;
    my $options = $param[1];

    my $key = $keys[int(rand(1))];

    my $param = Raisin::Param->new(
        named => $key eq 'named' ? 1 : 0,
        type => $param[0],
        spec => $param[1],
    );
    isa_ok $param, 'Raisin::Param';

    is $param->default, $options->[2], 'default';
    is $param->name, $options->[0], 'name';
    is $param->named, $key eq 'named' ? 1 : 0, 'named';
    is $param->required, $required, 'required';
    is $param->type, $options->[1], 'type';

    my @expected = (undef, 1);
    for my $v (@{ $values[$index] }) {
        is $param->validate(\$v), shift @expected, "validate $v: ${\$param->type->name}";
    }
    $index++;
}

done_testing;