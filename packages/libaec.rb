module STARMAN
  class Libaec < Package
    url 'https://gitlab.dkrz.de/k202009/libaec/uploads/631e85bcf877c2dcaca9b2e6d6526339/libaec-1.0.0.tar.gz'
    sha256 '3e79e33b380cb2f17323d3de5e70c4e656242a62bfbe72ffcea36adaa344c47d'
    version '1.0.0'

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --enable-silent-rules
      ]
      run './configure', *args
      run 'make'
      run 'make', 'check' unless skip_test?
      run 'make', 'install'
    end
  end
end
