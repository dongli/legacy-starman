module STARMAN
  class Superlu < Package
    homepage 'http://crd-legacy.lbl.gov/~xiaoye/SuperLU/'
    url 'http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_5.2.1.tar.gz'
    sha256 '28fb66d6107ee66248d5cf508c79de03d0621852a0ddeba7301801d3d859f463'
    version '5.2.1'
    language :c, :fortran

    option 'with-openmp', {
      desc: 'Build with OpenMP support.',
      accept_value: { boolean: CompilerStore.compiler(:c).feature?(:openmp) }
    }

    depends_on :openblas

    def install
      if OS.linux?
        FileUtils.cp 'MAKE_INC/make.linux', 'make.inc'
      elsif OS.mac?
        FileUtils.cp 'MAKE_INC/make.mac-x', 'make.inc'
      end
      replace 'make.inc', '-fopenmp', '' if not CompilerStore.compiler(:c).feature?(:openmp)
      args = %W[
        RANLIB=true
        CC="${CC}"
        FORTRAN="${FC}"
        SuperLUroot=#{FileUtils.pwd}
        SUPERLULIB=#{FileUtils.pwd}/lib/libsuperlu.a
        NOOPTS=-fPIC
        BLASLIB="-L#{Openblas.lib} -lopenblas"
      ]
      run 'make', 'lib', *args
      run 'make', 'testing' if not skip_test?
      work_in 'TESTING' do
        %w[stest dtest ctest ztest].each do |test|
          run 'make', *args
          %w[stest dtest ctest ztest].each do |test|
            CLI.blue_arrow `tail -1 #{test}.out`.chomp
          end
        end
      end
      FileUtils.mkdir_p "#{inc}/superlu"
      FileUtils.cp 'SRC/*.h', "#{inc}/superlu"
      FileUtils.mkdir_p lib
      FileUtils.cp 'lib/*', lib
    end
  end
end
