
  
  class Slidy < Formula
    desc "Pipeline, Template generator and package manager"
    homepage "https://github.com/Flutterando/slidy"
    url "https://github.com/Flutterando/slidy/archive/4.0.0+26.tar.gz"
    sha256 "15a06c49e863967b08662815f19690c3826fb6fe59d54c2a49b3e2727a17085f"
    license "MIT"
  
    depends_on "dart-lang/dart/dart" => :build


def install
    # Tell the pub server where these installations are coming from.
    ENV["PUB_ENVIRONMENT"] = "homebrew:fvm"

    system _dart/"dart", "pub", "get"
    # Build a native-code executable on 64-bit systems only. 32-bit Dart
    # doesn't support this.
    if Hardware::CPU.is_64_bit?
      _install_native_executable
    else
      _install_script_snapshot
    end
    chmod 0555, "#{bin}/slidy"
  end

  test do
    system "false"
  end

  private

  def _dart
    @_dart ||= Formula["dart-lang/dart/dart"].libexec/"bin"
  end

  def _install_native_executable
    system _dart/"dart", "compile", "exe", "bin/main.dart", "-o", "slidy"
    bin.install "slidy"
  end

  def _install_script_snapshot
    system _dart/"dart", "compile", "jit-snapshot",
           "-Dversion=#{_version}",
           "-o", "main.dart.app.snapshot",
           "bin/main.dart"
    lib.install "main.dart.app.snapshot"

    
    cp _dart/"dart", lib

    (bin/"slidy").write <<~SH
      #!/bin/sh
      exec "#{lib}/dart" "#{lib}/main.dart.app.snapshot" "$@"
    SH
  end
end
  
