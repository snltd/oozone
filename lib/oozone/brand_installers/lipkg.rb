# frozen_string_literal: true

require_relative 'ipkg'

module Oozone
  module BrandInstaller
    #
    # Linked ipkg zones are installed in exactly the same way as ipkg zones.
    #
    class Lipkg < Ipkg; end
  end
end
