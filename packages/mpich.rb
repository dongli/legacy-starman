module STARMAN
  class Mpich < Package
    url 'https://www.mpich.org/static/downloads/3.2/mpich-3.2.tar.gz'
    sha256 '0778679a6b693d7b7caff37ff9d2856dc2bfc51318bf8373859bfa74253da3dc'
    version '3.2'

    def shipped_wrappers
      return @wrappers if @wrappers
      @wrappers = {
        c: "#{bin}/mpicc",
        cxx: "#{bin}/mpicxx",
        fortran: "#{bin}/mpifort"
      }
      @wrappers
    end

    def install
      args = %W[
        --disable-dependency-tracking
        --disable-silent-rules
        --prefix=#{prefix}
      ]
      args << '--disable-fortran' unless CompilerStore.compiler(:fortran)
      run './configure', *args
      run 'make'
      run 'make', 'check' unless skip_test?
      run 'make', 'install'
    end
  end
end
