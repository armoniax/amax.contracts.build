class Amax < Formula
   # typed: false
   # frozen_string_literal: true

   homepage "https://github.com/armoniax/amachain"
   revision 0
   url "https://github.com/armoniax/amax.releases/blob/main/amax.chain/v0.5.0/amax-0.5.0.monterey.bottle.tar.gz"
   version "0.5.0"

   option :universal

   depends_on "gmp"
   depends_on "gettext"
   depends_on "openssl@1.1"
   depends_on "libusb"
   depends_on macos: :monterey
   depends_on arch: :intel

   bottle do
      root_url "https://github.com/armoniax/amax.releases/blob/main/amax.chain/v0.5.0"
      sha256 monterey: "a18a6b7ef74848c40d735f128147853b360fd62e0efea84d34ff45a4a3f18283"
   end
   def install
      raise "Error, only supporting binary packages at this time"
   end
end
__END__
