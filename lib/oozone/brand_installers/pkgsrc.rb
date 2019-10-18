require_relative 'ipkg'

module Oozone
  module BrandInstaller
    #
    # pkgsrc zones are installed in exactly the same way as ipkg zones.
    #
    class Pkgsrc < Ipkg; end
  end
end
