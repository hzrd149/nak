{
  buildGo125Module,
  lib,
  src,
  version,
}:

buildGo125Module {
  pname = "nak";
  inherit src version;

  vendorHash = "sha256-Umy4pbmLP4poBq71K+msv8YmfiX9XtWp2VmqCbrdZng=";

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  # The CLI test suite includes relay integration tests that require network access.
  doCheck = false;

  meta = {
    description = "Nostr army knife command-line tool";
    homepage = "https://github.com/fiatjaf/nak";
    license = lib.licenses.unlicense;
    mainProgram = "nak";
  };
}
