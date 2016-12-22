module STARMAN
  class Openldap < Package
    url 'ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.44.tgz'
    sha256 'd7de6bf3c67009c95525dde3a0212cc110d0a70b92af2af8e3ee800e81b88400'
    version '2.4.44'

    label :system_conflict if OS.ubuntu?

    depends_on :berkeleydb4
    depends_on :openssl

    def install
      args = %W[
        --disable-dependency-tracking
        --prefix=#{prefix}
        --enable-accesslog
        --enable-auditlog
        --enable-constraint
        --enable-dds
        --enable-deref
        --enable-dyngroup
        --enable-dynlist
        --enable-memberof
        --enable-ppolicy
        --enable-proxycache
        --enable-refint
        --enable-retcode
        --enable-seqmod
        --enable-translucent
        --enable-unique
        --enable-valsort
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
