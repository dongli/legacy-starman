module STARMAN
  class Scws < Package
    homepage 'https://github.com/hightman/scws'
    url 'https://github.com/hightman/scws/archive/1.2.3.tar.gz'
    sha256 '98e5932221029f507eadc762c4036eaf95f31f62f45f972401ec6952258feb10'
    version '1.2.3'
    filename 'scws-1.2.3.tar.gz'

    label :compiler_agnostic

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
      ]
      run './acprep'
      run './configure', *args
      run 'make install'
    end
  end
end
