module STARMAN
  class Openmpi < Package
    homepage 'https://www.open-mpi.org/'
    url 'https://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.2.tar.bz2'
    sha256 '8846e7e69a203db8f50af90fa037f0ba47e3f32e4c9ccdae2db22898fd4d1f59'
    version '1.10.2'
    language :c, :cxx, :fortran

    option :'with-fortran', {
      desc: 'Build Fortran MPI interface.',
      accept_value: { boolean: true }
    }
    option :'with-mpi-thread-multiple', {
      desc: 'Enable MPI_THREAD_MULTIPLE',
      accept_value: { boolean: true }
    }

    depends_on :libevent

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-silent-rules
        --enable-ipv6
        --with-libevent=#{Libevent.prefix}
        --with-sge
      ]
      args << '--disable-mpi-fortran' if not with_fortran?
      args << '--enable-mpi-thread-multiple' if with_mpi_thread_multiple?
      run './configure', *args
      run 'make', 'all'
      run 'make', 'check' if not skip_test?
      run 'make', 'install'
    end
  end
end
