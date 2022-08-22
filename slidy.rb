
  
  class Slidy < Formula
    desc "Simple cli to manage Flutter SDK versions per project"
    homepage "https://github.com/Flutterando/slidy"
    url "https://github.com/Flutterando/slidy/archive/4.0.0+8.tar.gz"
    sha256 "1a26f839b3ae42d8b4dc17676041fbbc89a31eb3243b37042d904b98aa47244e"
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
  
