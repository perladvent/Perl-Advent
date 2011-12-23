package Graphics::ColorNames::Metallic;
# Custom Metallic table for Graphics::ColorName,
# from Graphics::ColorNames doc, with additions from X table.

sub NamesRgbTable() {
use integer;
        return {
        copper => 0xb87333,
        silver => 0xe6e8fa, # others use C0C0C0 which is just light-grey :-(

        gold   => 0xcd7f32,
        gold1  => 0xffd700, # X
        gold2  => 0xeec900, # X
        gold3  => 0xcdad00, # X
        gold4  => 0x8b7500, # X
        };
}

 1;
