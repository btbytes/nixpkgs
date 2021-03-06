# NixOS tests for gnome-desktop-testing-runner using software
# See https://wiki.gnome.org/Initiatives/GnomeGoals/InstalledTests

{ system ? builtins.currentSystem,
  config ? {},
  pkgs ? import ../../.. { inherit system config; }
}:

with import ../../lib/testing-python.nix { inherit system pkgs; };
with pkgs.lib;

let

  callInstalledTest = pkgs.newScope { inherit makeInstalledTest; };

  makeInstalledTest =
    { # Package to test. Needs to have an installedTests output
      tested

      # Config to inject into machine
    , testConfig ? {}

      # Test script snippet to inject before gnome-desktop-testing-runner begins.
      # This is useful for extra setup the environment may need before the runner begins.
    , preTestScript ? ""

      # Does test need X11?
    , withX11 ? false

      # Extra flags to pass to gnome-desktop-testing-runner.
    , testRunnerFlags ? ""
    }:
    makeTest rec {
      name = tested.name;

      meta = {
        maintainers = tested.meta.maintainers;
      };

      machine = { ... }: {
        imports = [
          testConfig
        ] ++ optional withX11 ../common/x11.nix;

        environment.systemPackages = with pkgs; [ gnome-desktop-testing ];

      };

      testScript =
        optionalString withX11 ''
          machine.wait_for_x()
        '' +
        optionalString (preTestScript != "") ''
          ${preTestScript}
        '' +
        ''
          machine.succeed(
              "gnome-desktop-testing-runner ${testRunnerFlags} -d '${tested.installedTests}/share'"
          )
        '';
    };

in

{
  colord = callInstalledTest ./colord.nix {};
  flatpak = callInstalledTest ./flatpak.nix {};
  flatpak-builder = callInstalledTest ./flatpak-builder.nix {};
  fwupd = callInstalledTest ./fwupd.nix {};
  gdk-pixbuf = callInstalledTest ./gdk-pixbuf.nix {};
  gjs = callInstalledTest ./gjs.nix {};
  glib-networking = callInstalledTest ./glib-networking.nix {};
  gnome-photos = callInstalledTest ./gnome-photos.nix {};
  graphene = callInstalledTest ./graphene.nix {};
  ostree = callInstalledTest ./ostree.nix {};
  xdg-desktop-portal = callInstalledTest ./xdg-desktop-portal.nix {};
}
