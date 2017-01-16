module STARMAN
  class Nco < Package
    homepage 'http://nco.sourceforge.net'
    url 'https://downloads.sourceforge.net/project/nco/nco-4.6.1.tar.gz'
    sha256 '7433fe5901f48eb5170f24c6d53b484161e1c63884d9350600070573baf8b8b0'
    version '4.6.1'

    label :compiler_agnostic

    depends_on :flex if needs_build?
    depends_on :bison if needs_build?
    depends_on :antlr2
    depends_on :gsl
    depends_on :netcdf
    depends_on :texinfo if needs_build?
    depends_on :udunits

    def install
      args = %W[
        --prefix=#{prefix}
        --enable-netcdf4
        --enable-dap
        --enable-ncap2
        --enable-udunits2
        --enable-optimize-custom
        NETCDF_INC=#{Netcdf.inc}
        NETCDF_LIB=#{Netcdf.lib}
        NETCDF4_ROOT=#{Netcdf.prefix}
        NETCDF_ROOT=#{Netcdf.prefix}
        UDUNITS2_PATH=#{Udunits.prefix}
        ANTLR_ROOT=#{Antlr2.prefix}
      ]
      run './configure', *args
      inreplace 'src/nco/ncap_lex.l', 'yy_size_t yyget_leng', 'int yyget_leng' if OS.linux?
      run 'make'
      run 'make', 'check' if not skip_test?
      run 'make', 'install'
    end
  end
end
