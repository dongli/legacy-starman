module STARMAN
  class M4 < Package
    homepage 'https://www.gnu.org/software/m4'
    url 'http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz'
    sha256 '3ce725133ee552b8b4baca7837fb772940b25e81b2a9dc92537aeaf733538c9e'
    version '1.4.17'

    label :compiler_agnostic
    label :system_first, command: 'm4', version: Proc.new { |cmd|
      `#{cmd} --version`.match(/\d+\.\d+\.\d+?/)[0]
    }, version_condition: '>= 1.4.16'

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
      ]
      args << 'ac_cv_type_struct_sched_param=yes' if OS.mac? and CompilerStore.compiler(:c).vendor == :gnu
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
