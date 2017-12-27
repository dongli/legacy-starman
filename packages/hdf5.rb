module STARMAN
  class Hdf5 < Package
    homepage 'http://www.hdfgroup.org/HDF5'
    url 'https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.19/src/hdf5-1.8.19.tar.bz2'
    sha256 '59c03816105d57990329537ad1049ba22c2b8afe1890085f0c022b75f1727238'
    version '1.8.19'

    option 'with-mpi', {
      desc: 'Build with parallel IO. MPI library is needed.',
      accept_value: { boolean: false }
    }
    option 'with-threadsafe', {
      desc: 'Turn on thread safe.',
      accept_value: { boolean: false }
    }
    option 'with-cxx', {
      desc: 'Build C++ API bindings.',
      accept_value: { boolean: true }
    }
    option 'with-fortran', {
      desc: 'Build Fortran API bindings.',
      accept_value: { boolean: true }
    }

    language :c
    language :cxx if with_cxx?
    language :fortran if with_fortran?

    depends_on :szip
    depends_on :zlib
    depends_on :mpi if with_mpi?

    def install
      # When use --enable-threadsafe option, C++ and Fortran bindings are not working properly.
      if with_threadsafe?
        option('with-cxx').value = false
        option('with-fortran').value = false
      end
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
        args << '--enable-cxx'
      else
        args << '--disable-cxx'
      end
      if with_fortran?
        args << '--enable-fortran'
        args << '--enable-fortran2003' if CompilerStore.compiler(:fortran).feature?(:fortran2003)
      else
        args << '--disable-fortran'
      end
      args << '--enable-threadsafe' if with_threadsafe?
      run './configure', *args
      run 'make'
      run 'make', 'check' unless skip_test?
      run 'make', 'install'
    end
  end
end
