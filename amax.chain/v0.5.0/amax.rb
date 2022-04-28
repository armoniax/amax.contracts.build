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
      sha256 monterey: "8bb543fcfa3c1115b07d57fd881afa7c7752754d14c136cba24c17d3530762c8"
   end
   def install
      raise "Error, only supporting binary packages at this time"
   end
end
__END__
