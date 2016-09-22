module STARMAN
  class Libjpeg < Package
    homepage 'http://www.ijg.org'
    url 'http://www.ijg.org/files/jpegsrc.v8d.tar.gz'
    sha256 '00029b1473f0f0ea72fbca3230e8cb25797fbb27e58ae2e46bb8bf5a806fe0b3'
    version 'v8d'

    label :system_conflict if OS.mac?

    def install
      args = %W[
        --disable-dependency-tracking
        --prefix=#{prefix}
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
