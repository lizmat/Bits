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

# vim: expandtab shiftwidth=4
