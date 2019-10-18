require_relative 'ipkg'

module Oozone
  module BrandInstaller
    #
    # Sparse zones are installed in exactly the same way as ipkg zones.
    #
    class Sparse < Ipkg; end
  end
end
