module STARMAN
  class Bazel < Package
    url 'https://github.com/bazelbuild/bazel/archive/0.3.1.tar.gz'
    sha256 '52beafc9d78fc315115226f31425e21df1714d96c7dfcdeeb02306e2fe028dd8'
    version '0.3.1'
    filename 'bazel-0.3.1.tar.gz'

    label :compiler_agnostic

    def install
      ENV['EMBED_LABEL'] = "#{version}-starman"
      ENV['BAZEL_WRKDIR'] = "#{pwd}/work"
      run './compile.sh'
      run './output/bazel', '--output_user_root', "#{pwd}/output_user_root", 'build', 'scripts:bash_completion'
      mkdir_p bin
      mv 'scripts/packages/bazel.sh', "#{bin}/bazel"
      mv 'output/bazel', "#{bin}/bazel-real"
    end
  end
end
