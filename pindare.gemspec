# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pindare/version'

Gem::Specification.new do |s|
  # Infos de base / version
  s.name = 'pindare'
  s.version = Pindare::VERSION
  s.date = "2012-10-28"
  s.summary = "Manipulation des modèles EDO"
  s.license = 'MIT'

  s.description = <<-EOF
    Regroupement des méthodes et algorithmes pour tester et calibrer des modèles EDO.

    - Simulation avec différentes intégrations temporelles.
    - Construction de base de données.
    - Calibration par sensitivité approchée.
  EOF

  # Auteur / Contact
  s.author = 'Olivier Saut'
  s.email = 'osaut@airpost.net'
  s.homepage = 'http://kesaco.eu'

  # Fichiers et extensions
  s.files = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  # Dépendances
  gem 'celluloid'

  # Chemins
  s.require_paths = ["lib"]
end
