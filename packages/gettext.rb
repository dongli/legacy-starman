module STARMAN
  class Gettext < Package
    url 'https://ftpmirror.gnu.org/gettext/gettext-0.19.8.1.tar.xz'
    sha256 '105556dbc5c3fbbc2aa0edb46d22d055748b6f5c7cd7a8d99f8e7eb84e938be4'
    version '0.19.8.1'

    depends_on :libiconv
    depends_on :libxml2

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-silent-rules
        --disable-debug
        --with-included-gettext
        --with-included-glib
        --with-included-libcroco
        --with-included-libunistring
        --with-emacs
        --disable-java
        --disable-csharp
        --without-git
        --without-cvs
        --without-xz
        --with-libiconv-prefix=#{Libiconv.prefix}
        --with-libxml2-prefix=#{Libxml2.prefix}
      ]
      if OS.mac? and CompilerStore.compiler(:c).vendor == :gnu
        args << 'ac_cv_type_struct_sched_param=yes'
        inreplace 'gettext-runtime/configure', {
          'gt_cv_func_CFPreferencesCopyAppValue=yes' => 'gt_cv_func_CFPreferencesCopyAppValue=no',
          'gt_cv_func_CFLocaleCopyCurrent=yes' => 'gt_cv_func_CFLocaleCopyCurrent=no'
        }
        inreplace 'gettext-tools/configure', {
          'gt_cv_func_CFPreferencesCopyAppValue=yes' => 'gt_cv_func_CFPreferencesCopyAppValue=no',
          'gt_cv_func_CFLocaleCopyCurrent=yes' => 'gt_cv_func_CFLocaleCopyCurrent=no'
        }
      end
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
