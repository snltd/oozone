# frozen_string_literal: true

require_relative 'ipkg'

module Oozone
  module BrandInstaller
    #
    # Sparse zones are installed in exactly the same way as ipkg zones.
    #
    class Bhyve < Ipkg; end
  end
end
