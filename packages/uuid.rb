module STARMAN
  class Uuid < Package
    homepage 'http://www.ossp.org/pkg/lib/uuid/'
    url 'https://mirrors.ocf.berkeley.edu/debian/pool/main/o/ossp-uuid/ossp-uuid_1.6.2.orig.tar.gz'
    sha256 '11a615225baa5f8bb686824423f50e4427acd3f70d394765bdff32801f0fd5b0'
    version '1.6.2'

    def install
      # upstream ticket: http://cvs.ossp.org/tktview?tn=200
      # pkg-config --cflags uuid returns the wrong directory since we override the
      # default, but uuid.pc.in does not use it
      inreplace 'uuid.pc.in', {
        /^(exec_prefix)=\$\{prefix\}$/ => '\1=@\1@',
        /^(includedir)=\$\{prefix\}\/include$/ => '\1=@\1@',
        /^(libdir)=\$\{exec_prefix\}\/lib$/ => '\1=@\1@'
      }

      args = %W[
        --prefix=#{prefix}
        --includedir=#{inc}/ossp
        --without-perl
        --without-php
        --without-pgsql
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
