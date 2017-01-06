module STARMAN
  class Byacc < Package
    url 'ftp://invisible-island.net/byacc/byacc-20160606.tgz'
    sha256 'cc8fdced486cb70cec7a7c9358de836bfd267d19d6456760bb4721ccfea5ac91'
    version '20160606'

    label :system_first, command: 'yacc'

    def install
      run './configure', '--disable-debug', '--disable-dependency-tracking', "--prefix=#{prefix}"
      run 'make', 'install'
    end
  end
end
