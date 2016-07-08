module STARMAN
  class Arpack < Package
    homepage 'https://github.com/opencollab/arpack-ng'
    url 'https://github.com/opencollab/arpack-ng/archive/3.4.0.tar.gz'
    sha256 '69e9fa08bacb2475e636da05a6c222b17c67f1ebeab3793762062248dd9d842f'
    version '3.4.0'
    filename 'arpack-ng-3.4.0.tar.gz'

    option 'with-mpi', {
      desc: 'Build with parallel support.',
      accept_value: { :boolean => false }
    }

    depends_on :openblas

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --with-blas="-L#{Openblas.lib} -lopenblas"
      ]
      args << '--enable-mpi' if with_mpi?

      run './bootstrap'
      run './configure', *args
      run 'make'
      run 'make', 'check' if not skip_test?
      run 'make', 'install'
    end
  end
end
