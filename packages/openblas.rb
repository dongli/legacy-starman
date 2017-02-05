module STARMAN
  class Openblas < Package
    homepage 'http://www.openblas.net/'
    url 'https://github.com/xianyi/OpenBLAS/archive/v0.2.18.tar.gz'
    sha256 '7d9f8d4ea4a65ab68088f3bb557f03a7ac9cb5036ef2ba30546c3a28774a4112'
    version '0.2.18'
    filename 'openblas-0.2.18.tar.gz'
    language :c, :fortran

    option 'with-openmp', {
      desc: 'Build with OpenMP support.',
      accept_value: { boolean: CompilerStore.compiler(:c).feature?(:openmp) }
    }
    option 'with-lapack', {
      desc: 'Build an internal version of LAPACK.',
      accept_value: { boolean: true }
    }

    def install
      ENV['DYNAMIC_ARCH'] = '1'
      ENV['USE_OPENMP'] = '1' if with_openmp?
      ENV['NO_LAPACK'] = '1' if not with_lapack?
      ENV['NO_LAPACKE'] = '1' if not with_lapack?
      if OS.neokylin?
        ENV['NO_AVX'] = '1'
        ENV['NO_AVX2'] = '1'
      end
      run 'make', 'libs', 'netlib', 'shared'
      run 'make', 'tests' if not skip_test?
      run 'make', "PREFIX=#{prefix}", 'install'
    end
  end
end
