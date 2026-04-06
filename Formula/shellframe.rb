class Shellframe < Formula
  desc "Multi-tab GUI terminal wrapper with clipboard image paste for AI CLIs"
  homepage "https://github.com/h2ocloud/shellframe"
  url "https://github.com/h2ocloud/shellframe.git",
      tag:      "v0.3.0",
      revision: "124375d"
  license "MIT"
  head "https://github.com/h2ocloud/shellframe.git", branch: "main"

  depends_on "python@3.12"

  def install
    # Install into libexec to keep it self-contained
    libexec.install Dir["*"]

    # Create venv and install Python deps
    venv = libexec/".venv"
    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", venv.to_s
    system venv/"bin/pip", "install", "-q", "-r", libexec/"requirements.txt"

    # CLI launcher
    (bin/"shellframe").write <<~SH
      #!/bin/bash
      if [ -f "$HOME/.zprofile" ]; then source "$HOME/.zprofile" 2>/dev/null; fi
      if [ -f "$HOME/.zshrc" ]; then source "$HOME/.zshrc" 2>/dev/null; fi
      exec "#{libexec}/.venv/bin/python" "#{libexec}/main.py" "$@"
    SH

    # sfctl launcher
    (bin/"sfctl").write <<~SH
      #!/bin/bash
      exec "#{libexec}/.venv/bin/python" "#{libexec}/sfctl.py" "$@"
    SH

    # Symlink .app for Spotlight
    prefix.install libexec/"ShellFrame.app"
  end

  def post_install
    # Symlink to ~/Applications for Spotlight/Launchpad
    app_link = Pathname.new(Dir.home)/"Applications/ShellFrame.app"
    unless app_link.exist?
      app_link.make_symlink(prefix/"ShellFrame.app")
    end
  end

  def caveats
    <<~EOS
      ShellFrame has been installed!

      Launch from terminal:
        shellframe

      Or search "ShellFrame" in Spotlight.

      AI remote control:
        sfctl reload    # hot-reload bridge after code changes
        sfctl status    # check bridge status
    EOS
  end

  test do
    assert_match "ShellFrame", shell_output("#{bin}/shellframe --help 2>&1", 1)
  end
end
