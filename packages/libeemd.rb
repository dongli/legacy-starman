module STARMAN
  class Libeemd < Package
    url 'https://bitbucket.org/luukko/libeemd/get/v1.4.tar.gz'
    sha256 'c484f4287f4469f3ac100cf4ecead8fd24bf43854efa63650934dd698d6b298b'
    version '1.4'
    filename 'libeemd-1.4.tar.gz'

    depends_on :gsl
    depends_on :pkgconfig if needs_build?

    patch :DATA if OS.mac?

    def install
      CLI.report_error "You should use a C compiler with OpenMP support!" unless CompilerStore.compiler(:c).feature? :openmp
      inreplace 'Makefile', 'gcc', "#{CompilerStore.compiler(:c).command}"
      run 'make'
      run 'make', 'install', "PREFIX=#{prefix}"
    end
  end
end

__END__
--- a/Makefile	2016-09-19 16:58:13.000000000 +0900
+++ b/Makefile	2016-12-08 11:50:50.000000000 +0900
@@ -23,7 +23,7 @@
 endef
 export uninstall_msg

-all: libeemd.so.$(version) libeemd.a eemd.h
+all: libeemd.$(version).dylib libeemd.a eemd.h

 clean:
	rm -f libeemd.so libeemd.so.$(version) libeemd.a eemd.h obj/eemd.o
@@ -34,8 +34,8 @@
	install -d $(PREFIX)/lib
	install -m644 eemd.h $(PREFIX)/include
	install -m644 libeemd.a $(PREFIX)/lib
-	install libeemd.so.$(version) $(PREFIX)/lib
-	cp -Pf libeemd.so $(PREFIX)/lib
+	install libeemd.$(version).dylib $(PREFIX)/lib
+	cp -Pf libeemd.dylib $(PREFIX)/lib

 uninstall:
	@echo "$$uninstall_msg"
@@ -49,9 +49,9 @@
 libeemd.a: obj/eemd.o
	$(AR) rcs $@ $^

-libeemd.so.$(version): src/eemd.c src/eemd.h
-	gcc $(commonflags) $< -fPIC -shared -Wl,$(SONAME),$@ $(gsl_flags) -o $@
-	ln -sf $@ libeemd.so
+libeemd.$(version).dylib: src/eemd.c src/eemd.h
+	gcc $(commonflags) $< -fPIC -dynamiclib -Wl,$(SONAME),$@ $(gsl_flags) -o $@
+	ln -sf $@ libeemd.dylib

 eemd.h: src/eemd.h
	cp $< $@
