{ lib, fetchFromGitHub
, python38, python38Packages
}:

let
  deps = with python38Packages; [
    graphviz pydot palettable sympy numpy pint django_1_11 mpmath dateutil colorama setuptools packaging
  ];
  pythonEnv = python38.withPackages (p: deps);
in
  python38Packages.buildPythonApplication rec {
    pname = "mathics";
    version = "1.1-rc0";

    src = fetchFromGitHub {
      owner = "mathics";
      repo = "Mathics";
      rev = "c1c38ad824da006c529699ac4d3ca7ad1eb97c3c";
      sha256 = "0lg47n6czji2kg54k0cs2czczxr7hys190m27w3wir2nb8wzirgd";
    };

    propagatedBuildInputs = deps;

    postPatch = ''
      substituteInPlace mathics/server.py \
        --replace "sys.executable, " ""
    '';

    doCheck = false;

    postInstall = ''
      for manage in $(find $out -name manage.py); do
        chmod +x $manage
        wrapProgram $manage --set PYTHONPATH "$PYTHONPATH:${pythonEnv}/${pythonEnv.sitePackages}"
      done
    '';

    disabled = !python38Packages.isPy3k;
    meta = {
      broken = false;

      description = "A free, light-weight alternative to Mathematica";
      homepage = https://mathics.github.io/;
      license = lib.licenses.gpl3;
      maintainers = [ lib.maintainers.suhr ];
    };
  }
