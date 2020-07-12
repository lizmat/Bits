use v6.c;
use Test;
use Bits;

# value, bitcnt, bits, bitswap, bit(1)
my @tests = (
 -9,  1,  (3,),     8, False,
 -8,  3,  (0,1,2),  7, True,
 -7,  2,  (1,2),    6, True,
 -6,  2,  (0,2),    5, False,
 -5,  1,  (2,),     4, False,
 -4,  2,  (0,1),    3, True,
 -3,  1,  (1,),     2, True,
 -2,  1,  (0,),     1, False,
 -1,  0,  (),       0, False,
  0,  0,  (),      -1, False,
  1,  1,  (0,),    -2, False,
  2,  1,  (1,),    -3, True,
  3,  2,  (0,1),   -4, True,
  4,  1,  (2,),    -5, False,
  5,  2,  (0,2),   -6, False,
  6,  2,  (1,2),   -7, True,
  7,  3,  (0,1,2), -8, True,
  8,  1,  (3,),    -9, False,
  9,  2,  (0,3),  -10, False,
);

plan (@tests / 5) * 4;

for @tests -> $value, $bitcnt, $bits, $bitswap, $bit1 {
    is bitcnt($value), $bitcnt,         "is bitcnt($value) == $bitcnt?";
    is-deeply bits($value).List, $bits, "is bits($value) == $bits?";
    is bitswap($value), $bitswap,       "is bitswap($value) == $bitswap";
    is bit($value,1),  $bit1,           "is bit($value,1) $bit1?";
}

# vim: expandtab shiftwidth=4
