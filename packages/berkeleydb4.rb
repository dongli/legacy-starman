module STARMAN
  class Berkeleydb4 < Package
    homepage 'https://www.oracle.com/technology/products/berkeley-db/index.html'
    url 'http://download.oracle.com/berkeley-db/db-4.8.30.tar.gz'
    sha256 'e0491a07cdb21fb9aa82773bbbedaeb7639cbd0e7f96147ab46141e0045db72a'
    version '4.8.30'

    label :compiler_agnostic

    patch :DATA if CompilerStore.compiler(:c).vendor == :llvm

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-debug
        --enable-cxx
      ]
      work_in 'build_unix' do
        run '../dist/configure', *args
        run 'make', 'install'
      end
    end
  end
end

__END__
diff -Naur a/dbinc/atomic.h b/dbinc/atomic.h
--- a/dbinc/atomic.h	2010-04-13 04:25:22.000000000 +0800
+++ b/dbinc/atomic.h	2017-01-03 09:58:09.000000000 +0800
@@ -144,7 +144,7 @@
 #define	atomic_inc(env, p)	__atomic_inc(p)
 #define	atomic_dec(env, p)	__atomic_dec(p)
 #define	atomic_compare_exchange(env, p, o, n)	\
-	__atomic_compare_exchange((p), (o), (n))
+	__atomic_compare_exchange_db((p), (o), (n))
 static inline int __atomic_inc(db_atomic_t *p)
 {
 	int	temp;
@@ -176,7 +176,7 @@
  * http://gcc.gnu.org/onlinedocs/gcc-4.1.0/gcc/Atomic-Builtins.html
  * which configure could be changed to use.
  */
-static inline int __atomic_compare_exchange(
+static inline int __atomic_compare_exchange_db(
 	db_atomic_t *p, atomic_value_t oldval, atomic_value_t newval)
 {
 	atomic_value_t was;
