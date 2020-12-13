use v6.*;

module Bits:ver<0.0.4>:auth<cpan:ELIZABETH> {
    use nqp;

    my constant $nibble2pos = nqp::list(
      nqp::list_i(),          #  0
      nqp::list_i(0),         #  1
      nqp::list_i(1),         #  2
      nqp::list_i(0,1),       #  3
      nqp::list_i(2),         #  4
      nqp::list_i(0,2),       #  5
      nqp::list_i(1,2),       #  6
      nqp::list_i(0,1,2),     #  7
      nqp::list_i(3),         #  8
      nqp::list_i(0,3),       #  9
      nqp::list_i(1,3),       # 10
      nqp::list_i(0,1,3),     # 11
      nqp::list_i(2,3),       # 12
      nqp::list_i(0,2,3),     # 13
      nqp::list_i(1,2,3),     # 14
      nqp::list_i(0,1,2,3)    # 15
    );

    my class IterateBits does Iterator {
        has Int $!bitmap;   # the bitmap we're looking at
        has int $!offset;   # the current offset towards nibbles
        has     $!list;     # list of positions for current nibble

        method !SET-SELF(\bitmap) {
            $!bitmap := nqp::islt_I(nqp::decont(bitmap),0)
              ?? bitswap(bitmap)
              !! nqp::decont(bitmap);
            $!offset = -4;
            $!list  := nqp::atpos($nibble2pos,0);
            self
        }
        method new(\bitmap) { nqp::create(self)!SET-SELF(bitmap) }

        method pull-one() {
            nqp::if(
              nqp::elems($!list),
              nqp::add_i($!offset,nqp::shift_i($!list)),   # value ready
              nqp::if(                                     # value NOT ready
                $!bitmap,
                nqp::stmts(                                 # not done yet
                  nqp::while(
                    $!bitmap && nqp::isfalse(
                      my int $index = nqp::bitand_I($!bitmap,15,Int)
                    ),
                    nqp::stmts(                              # next nibble
                      ($!offset  = $!offset + 4),
                      ($!bitmap := nqp::bitshiftr_I($!bitmap,4,Int))
                    )
                  ),
                  nqp::if(                                  # done searching
                    $!bitmap,
                    nqp::stmts(                              # found nibble
                      (my int $pos = nqp::add_i(              # convert index
                        ($!offset = nqp::add_i($!offset,4)),  # to position by
                        nqp::shift_i(                         # fetching value
                          ($!list := nqp::clone(              # from the right
                            nqp::atpos($nibble2pos,$index)    # list
                          ))
                        )
                      )),
                      ($!bitmap := nqp::bitshiftr_I($!bitmap,4,Int)),
                      $pos
                    ),
                    IterationEnd                              # done now
                  )
                ),
                IterationEnd                                 # already done
              )
            )
        }
    }

    sub bitswap(Int:D \bitmap --> Int:D) is export {
        nqp::neg_I(nqp::add_I(nqp::decont(bitmap),1,Int),Int)
    }

    sub bit(Int:D \bitmap, UInt:D \offset --> Bool:D) is export {
        nqp::hllbool(
          nqp::bitand_I(
            nqp::if(
              nqp::islt_I(nqp::decont(bitmap),0),
              bitswap(bitmap),
              nqp::decont(bitmap)
            ),
            nqp::bitshiftl_I(1,offset,Int),
            Int
          )
        )
    }

    sub bits(Int:D \bitmap --> Seq:D) is export {
        Seq.new: IterateBits.new(bitmap)
    }

    # nibble -> number of bits conversion
    my constant $nibble2bits = nqp::list_i(0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4);

    sub bitcnt(Int:D \bitmap --> Int:D) is export {
        my $bitmap := nqp::decont(bitmap);
        nqp::if(
          $bitmap && nqp::isne_I($bitmap,-1),
          nqp::stmts(                                 # has significant bits
            ($bitmap := nqp::if(
              nqp::isle_I($bitmap,0),
              bitswap($bitmap),
              $bitmap
            )),
            (my int $bits = 0),
            nqp::while(
              $bitmap,
              nqp::stmts(
                ($bits = $bits + nqp::atpos_i(
                  $nibble2bits,
                  nqp::bitand_I($bitmap,0x0f,Int)
                )),
                ($bitmap := nqp::bitshiftr_I($bitmap,4,Int)),
              )
            ),
            $bits
          ),
          0                                           # no significant bits
        )
    }
}

=begin pod

=head1 NAME

Bits - provide bit related functions for arbitrarily large integers

=head1 SYNOPSIS

  use Bits;  # exports "bit", "bits", "bitcnt", "bitswap"

  say bit(8, 3);    # 1000 -> True
  say bit(7, 3);    # 0111 -> False

  say bits(8);      # 1000 -> (3,).Seq
  say bits(7);      # 0111 -> (0,1,2).Seq

  say bitcnt(8);    # 1000 -> 1
  say bitcnt(7);    # 0111 -> 3

  say bitswap(1);   # 0001 -> 1110
  say bitswap(-1);  # 1111 -> 0000

=head1 DESCRIPTION

This module exports a number of function to handle significant bits in
arbitrarily large integer values, aka bitmaps.  If the specified value is
zero or positive, then the on-bits will be considered significant.  If the
specified value is negative, then the off-bits in the value will be
considered significant.

=head1 SUBROUTINES

=head2 bit

  sub bit(Int:D value, UInt:D bit --> Bool:D)

Takes an integer value and a bit number and returns whether that bit is
significant (1 for positive values, 0 for negative values).

=head2 bits

  sub bits(Int:D value --> Seq:D)

Takes an integer value and returns a C<Seq>uence of the bit numbers that are
significant in the value.  For negative values, these are the bits that are 0.

=head2 bitcnt

  sub bitcnt(Int:D value --> Int:D)

Takes an integer value and returns the number of significant bits that are set
in the value.  For negative values, this is the number of bits that are 0.

=head2 bitswap

  sub bitswap(Int:D value --> Int:D)

Takes an integer value and returns an integer value with all of the 1-bits
turned to 0-bits and vice-versa.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Bits .  Comments and Pull
Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2019-2020 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
