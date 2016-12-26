module STARMAN
  class Libiconv < Package
    homepage 'https://www.gnu.org/software/libiconv/'
    url 'http://ftpmirror.gnu.org/libiconv/libiconv-1.14.tar.gz'
    sha256 '72b24ded17d687193c3366d0ebe7cde1e6b18f0df8c55438ac95be39e8a30613'
    version '1.14'

    # Mac ships one with no 'lib' prefix in some symbols.
    label :system_conflict if OS.mac?

    patch :DATA

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-debug
        --disable-dependency-tracking
        --enable-extra-encodings
      ]
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end

__END__
diff -Naur a/srclib/stdio.in.h b/srclib/stdio.in.h
--- a/srclib/stdio.in.h	2011-08-07 21:42:06.000000000 +0800
+++ b/srclib/stdio.in.h	2016-12-26 10:58:38.000000000 +0800
@@ -695,8 +695,12 @@
 /* It is very rare that the developer ever has full control of stdin,
    so any use of gets warrants an unconditional warning.  Assume it is
    always declared, since it is required by C89.  */
+#if defined(__GLIBC__) && !defined(__UCLIBC__) && defined(__GLIBC_PREREQ)
+#if !__GLIBC_PREREQ(2,16)
 _GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");
 #endif
+#endif
+#endif


 #if @GNULIB_OBSTACK_PRINTF@ || @GNULIB_OBSTACK_PRINTF_POSIX@
