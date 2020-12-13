NAME
====

Bits - provide bit related functions for arbitrarily large integers

SYNOPSIS
========

    use Bits;  # exports "bit", "bits", "bitcnt", "bitswap"

    say bit(8, 3);    # 1000 -> True
    say bit(7, 3);    # 0111 -> False

    say bits(8);      # 1000 -> (3,).Seq
    say bits(7);      # 0111 -> (0,1,2).Seq

    say bitcnt(8);    # 1000 -> 1
    say bitcnt(7);    # 0111 -> 3

    say bitswap(1);   # 0001 -> 1110
    say bitswap(-1);  # 1111 -> 0000

DESCRIPTION
===========

This module exports a number of function to handle significant bits in arbitrarily large integer values, aka bitmaps. If the specified value is zero or positive, then the on-bits will be considered significant. If the specified value is negative, then the off-bits in the value will be considered significant.

SUBROUTINES
===========

bit
---

    sub bit(Int:D value, UInt:D bit --> Bool:D)

Takes an integer value and a bit number and returns whether that bit is significant (1 for positive values, 0 for negative values).

bits
----

    sub bits(Int:D value --> Seq:D)

Takes an integer value and returns a `Seq`uence of the bit numbers that are significant in the value. For negative values, these are the bits that are 0.

bitcnt
------

    sub bitcnt(Int:D value --> Int:D)

Takes an integer value and returns the number of significant bits that are set in the value. For negative values, this is the number of bits that are 0.

bitswap
-------

    sub bitswap(Int:D value --> Int:D)

Takes an integer value and returns an integer value with all of the 1-bits turned to 0-bits and vice-versa.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Bits . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2019-2020 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

