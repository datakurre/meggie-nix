{ pkgs }:

let

  # Import all generated requirements
  requirementsFunc = import ./python-packages.nix {
    inherit pkgs;
    inherit (builtins) fetchurl;
    inherit (pkgs) fetchgit fetchhg;
  };

  # List package names in generated requirements requirements
  requirementsNames = pkgs.lib.attrNames (requirementsFunc {} {});


  # Target Python package overrides
  packageOverrides = pkgs.lib.foldr pkgs.lib.composeExtensions (self: super: { }) [

    # Import generated requirements not available in nixpkgs (or override them)
    (self: super:
      let
        generated = requirementsFunc self super;
      in

      # Import generated requirements not available
      (pkgs.lib.listToAttrs (map
        (name: { name = name;
                 value = builtins.getAttr name generated; })
        (builtins.filter (x: (! builtins.hasAttr x pkgs.python39Packages)) requirementsNames)
      ))
    )

  ];

  python = (pkgs.python39.override {
    inherit packageOverrides;
  });

in

python.pkgs.buildPythonApplication rec {
  pname = "meggie";
  version = "1.3.4";

  src = python.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "DIxcA32o8VGJ/H5WcwS/qNSVCSTUxVbzJuXJjD9Lh8E=";
  };

  doCheck = false;

  propagatedBuildInputs = with python.pkgs;
    [
      setuptools
      matplotlib
      pyqt5
      h5io
      scikit-learn
      python-json-logger
      mne
    ];

  nativeBuildInputs = with pkgs; [
    qt5.wrapQtAppsHook
  ];

  postFixup = ''
    wrapProgram $out/bin/meggie \
      "''${qtWrapperArgs[@]}"
  '';

  meta = with pkgs.lib; {
    homepage = "https://github.com/cibr-jyu/meggie";
    description = "User-friendly MNE-python based graphical user interface to do MEG and EEG analysis with multiple subjects";
    license = licenses.bsd3;
  };
}
