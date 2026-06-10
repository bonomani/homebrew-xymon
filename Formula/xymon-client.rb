class XymonClient < Formula
  desc "Xymon network and systems monitor (client only)"
  homepage "https://xymon.com/"
  license "GPL-2.0-or-later"

  # No upstream release tarball is published yet. Build from main for now.
  # Once `rel-4.3.31` is cut, pin url + sha256 (see Formula/xymon.rb) and drop --HEAD.
  head "https://github.com/xymon-monitoring/xymon.git", branch: "main"

  depends_on "openssl@3"

  # The client and server install the same `xymond` deobfuscation tools; they
  # conflict if both are linked. Install the client keg-only or unlink the other.
  conflicts_with "xymon", because: "both install overlapping client tools"

  def install
    # configure.client is env-var driven too. CONFTYPE selects the client
    # config flavor; XYMSRV is the server this client reports to (set at runtime).
    ENV["CONFTYPE"]      = "client"
    ENV["XYMONUSER"]     = ENV["USER"]
    ENV["XYMONTOPDIR"]   = prefix.to_s
    ENV["XYMONHOSTNAME"] = "localhost"
    ENV["XYMONHOSTIP"]   = "127.0.0.1"
    ENV["XYMSRV"]        = "127.0.0.1"

    system "./configure", "--client"
    system "make"
    system "make", "install", "PKGBUILD=1"
  end

  def caveats
    <<~EOS
      Xymon client installed under #{opt_prefix}.
      Set XYMSRV (the server address) in etc/xymonclient.cfg and arrange a
      launch mechanism (launchd/cron) before running runclient.sh.
    EOS
  end

  test do
    assert_predicate prefix/"client", :exist?
  end
end
