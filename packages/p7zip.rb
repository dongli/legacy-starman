module STARMAN
  class P7zip < Package
    url 'https://downloads.sourceforge.net/project/p7zip/p7zip/16.02/p7zip_16.02_src_all.tar.bz2'
    sha256 '5eb20ac0e2944f6cb9c2d51dd6c4518941c185347d4089ea89087ffdd6e2341f'
    version '16.02'

    label :compiler_agnostic

    def install
      if OS.mac? and CompilerStore.compiler(:c).vendor == :llvm
        cp 'makefile.macosx_llvm_64bits', 'makefile.machine'
      end
      run 'make', 'all3', "CC=#{CompilerStore.compiler(:c).command}", "CXX=#{CompilerStore.compiler(:cxx).command}"
      run 'make', "DEST_HOME=#{prefix}", "DEST_MAN=#{man}", 'install'
    end
  end
end
