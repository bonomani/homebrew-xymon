class Xymon < Formula
  desc "Xymon network and systems monitor (server)"
  homepage "https://xymon.com/"
  license "GPL-2.0-or-later"

  # No upstream release tarball is published yet. Build from main for now.
  # Once `rel-4.3.31` is cut by the release workflow, pin a stable source:
  #   url "https://github.com/xymon-monitoring/xymon/releases/download/rel-4.3.31/xymon-4.3.31.tar.gz"
  #   sha256 "<from the published xymon-4.3.31.tar.gz.sha256>"
  # and drop the --HEAD requirement.
  head "https://github.com/xymon-monitoring/xymon.git", branch: "main"

  depends_on "openssl@3"
  depends_on "pcre2"
  depends_on "rrdtool"
  depends_on "fping"

  def install
    # configure.server is fully env-var driven (no stdin prompts) and requires
    # XYMONUSER to be a real OS user, so build as the invoking user.
    # PKGBUILD=1 makes `make install` skip the chown/chgrp/user-creation steps,
    # so everything lands cleanly under the Homebrew prefix with no root.
    ENV["ENABLESSL"]         = "y"
    ENV["ENABLELDAP"]        = "n"
    ENV["XYMONUSER"]         = ENV["USER"]
    ENV["XYMONTOPDIR"]       = prefix.to_s
    ENV["XYMONHOSTURL"]      = "/xymon"
    ENV["CGIDIR"]            = "#{prefix}/cgi-bin"
    ENV["XYMONCGIURL"]       = "/xymon-cgi"
    ENV["SECURECGIDIR"]      = "#{prefix}/cgi-secure"
    ENV["SECUREXYMONCGIURL"] = "/xymon-seccgi"
    ENV["HTTPDGID"]          = "_www"
    ENV["XYMONLOGDIR"]       = "#{var}/log/xymon"
    ENV["XYMONHOSTNAME"]     = "localhost"
    ENV["XYMONHOSTIP"]       = "127.0.0.1"
    ENV["MANROOT"]           = man.to_s

    system "./configure", "--server"
    system "make"
    # INSTALLROOT unset → install directly into XYMONTOPDIR (= prefix).
    system "make", "install", "PKGBUILD=1"
  end

  def caveats
    <<~EOS
      Xymon server installed under #{opt_prefix}.
      This is a build-only formula: it does NOT create a xymon user, web server
      config, or a launchd service. Configure runtime paths, the monitored-host
      list (etc/hosts.cfg), and a launch mechanism manually before starting xymond.
    EOS
  end

  test do
    assert_predicate bin/"xymond", :exist?
  end
end
