module STARMAN
  class Libyaml < Package
    homepage 'http://pyyaml.org/wiki/LibYAML'
    url 'http://pyyaml.org/download/libyaml/yaml-0.1.6.tar.gz'
    sha256 '7da6971b4bd08a986dd2a61353bc422362bd0edcc67d7ebaac68c95f74182749'
    version '0.1.6'

    has_patch

    def install
      run './configure', "--prefix=#{prefix}", '--disable-dependency-tracking'
      run 'make', 'install'
    end
  end
end

__END__
# HG changeset patch
# User Kirill Simonov <xi@resolvent.net>
# Date 1417197312 21600
# Node ID 2b9156756423e967cfd09a61d125d883fca6f4f2
# Parent  053f53a381ff6adbbc93a31ab7fdee06a16c8a33
Removed invalid simple key assertion (thank to Jonathan Gray).

diff --git a/src/scanner.c b/src/scanner.c
--- a/src/scanner.c
+++ b/src/scanner.c
@@ -1106,13 +1106,6 @@
             && parser->indent == (ptrdiff_t)parser->mark.column);

     /*
-     * A simple key is required only when it is the first token in the current
-     * line.  Therefore it is always allowed.  But we add a check anyway.
-     */
-
-    assert(parser->simple_key_allowed || !required);    /* Impossible. */
-
-    /*
      * If the current position may start a simple key, save it.
      */
