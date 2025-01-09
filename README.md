[![Actions Status](https://github.com/lizmat/Bits/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/Bits/actions) [![Actions Status](https://github.com/lizmat/Bits/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/Bits/actions) [![Actions Status](https://github.com/lizmat/Bits/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/Bits/actions)

NAME
====

Bits - provide bit related functions for arbitrarily large integers

SYNOPSIS
========

```raku
use Bits;  # exports "bit", "bits", "bitcnt", "bitswap"

say bit(8, 3);    # 1000 -> True
say bit(7, 3);    # 0111 -> False

say bits(8);      # 1000 -> (3,).Seq
say bits(7);      # 0111 -> (0,1,2).Seq

say bitcnt(8);    # 1000 -> 1
say bitcnt(7);    # 0111 -> 3

say bitswap(1);   # 0001 -> 1110
say bitswap(-1);  # 1111 -> 0000
```

DESCRIPTION
===========

This module exports a number of function to handle significant bits in arbitrarily large integer values, aka bitmaps. If the specified value is zero or positive, then the on-bits will be considered significant. If the specified value is negative, then the off-bits in the value will be considered significant.

SUBROUTINES
===========

bit
---

```raku
sub bit(Int:D value, UInt:D bit --> Bool:D)
```

Takes an integer value and a bit number and returns whether that bit is significant (1 for positive values, 0 for negative values).

bits
----

```raku
sub bits(Int:D value --> Seq:D)
```

Takes an integer value and returns a `Seq`uence of the bit numbers that are significant in the value. For negative values, these are the bits that are 0.

bitcnt
------

```raku
sub bitcnt(Int:D value --> Int:D)
```

Takes an integer value and returns the number of significant bits that are set in the value. For negative values, this is the number of bits that are 0.

bitswap
-------

```raku
sub bitswap(Int:D value --> Int:D)
```

Takes an integer value and returns an integer value with all of the 1-bits turned to 0-bits and vice-versa.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Bits . Comments and Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2019, 2020, 2021, 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

