{ pkgs }:

let

  packageOverrides =
    self: super:
      # Read dependencies resolved with pip2nix
      let overrides =
        (import ./python-packages.nix {
           inherit pkgs;
           inherit (pkgs) fetchurl fetchgit fetchhg;
         }) self super;
      in
      {
        # Use only dependencies not available in nixpkgs
        inherit (overrides)
        "h5io"
        "mne";
        # Map aliases required for the previous dependenvies
        "Jinja2" = self."jinja2";
      };

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
