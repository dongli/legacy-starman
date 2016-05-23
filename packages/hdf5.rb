module STARMAN
  class Hdf5 < Package
    homepage 'http://www.hdfgroup.org/HDF5'
    url 'https://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.16/src/hdf5-1.8.16.tar.bz2'
    sha256 '13aaae5ba10b70749ee1718816a4b4bfead897c2fcb72c24176e759aec4598c6'
    version '1.8.16'

    option 'with-mpi', {
      :desc => 'Build with parallel IO. MPI library is needed.',
      :accept_value => { :boolean => false }
    }
    option 'with-cxx', {
      :desc => 'Build C++ API bindings.',
      :accept_value => { :boolean => true }
    }
    option 'with-fortran', {
      :desc => 'Build Fortran API bindings.',
      :accept_value => { :boolean => true }
    }

    language :c
    language :cxx if with_cxx?
    language :fortran if with_fortran?

    depends_on :szip
    depends_on :zlib
    depends_on :mpi if with_mpi?

    def install
      args = %W[
        --prefix=#{prefix}
        --enable-production
        --enable-debug=no
        --disable-dependency-tracking
        --with-zlib=#{Zlib.prefix}
        --with-szlib=#{Szip.prefix}
        --enable-static=yes
        --enable-shared=yes
      ]
      if with_cxx?
        args << '-enable-cxx'
      else
        args << '--disable-cxx'
      end
      if with_fortran?
        args << '--enable-fortran'
        args << '--enable-fortran2003' if CompilerStore.compiler(:fortran).feature_fortran2003?
      else
        args << '--disable-fortran'
      end
      run './configure', *args
      run 'make'
      run 'make', 'check' if not skip_test?
      run 'make', 'install'
    end
  end
end
