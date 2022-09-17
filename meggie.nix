{ pkgs }:

let
  packageOverrides = 
    self: super: 
      let overrides = 
        (import ./python-packages.nix {
           inherit pkgs;
           inherit (pkgs) fetchurl fetchgit fetchhg;
         }) self super;
      in 
        overrides // {      

          "Pillow" = super.pillow;
          "pyparsing" = super.pyparsing;
          "packaging" = super.packaging;
          "kiwisolver" = super.kiwisolver;
          "numpy" = super.numpy;
          "scipy" = super.scipy;
          "matplotlib" = super.matplotlib;
          "h5py" = super.h5py;
          "scikit-learn" = super.scikit-learn;

          "contourpy" = overrides."contourpy".overrideAttrs (oldAttrs: {
            propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ super.pybind11 ];
          });

        };

  python = (pkgs.python39.override {
    packageOverrides = packageOverrides;
  });

  mne = python.pkgs.mne;

in

python.pkgs.buildPythonApplication rec {
  pname = "meggie";
  version = "1.3.4";

  src = python.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "DIxcA32o8VGJ/H5WcwS/qNSVCSTUxVbzJuXJjD9Lh8E=";
  };

  doCheck = false;

  propagatedBuildInputs = 
    [ 
      python.pkgs.setuptools
      python.pkgs.matplotlib
      python.pkgs.pyqt5 
      python.pkgs.h5io
      python.pkgs.scikit-learn
      python.pkgs."python-json-logger"
      mne
    ];

  nativeBuildInputs = [ 
    pkgs.qt5.wrapQtAppsHook 
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
