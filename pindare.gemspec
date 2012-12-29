# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pindare/version'

Gem::Specification.new do |gem|
  # Infos de base / version
  gem.name = 'pindare'
  gem.version = Pindare::VERSION
  gem.date = "2012-10-28"
  gem.summary = "Manipulation des modèles EDO"
  gem.license = 'MIT'

  gem.description = <<-EOF
    Regroupement des méthodes et algorithmes pour tester et calibrer des modèles EDO.

    - Simulation avec différentes intégrations temporellegem.
    - Construction de base de donnéegem.
    - Calibration par sensitivité approchée.
  EOF

  # Auteur / Contact
  gem.author = 'Olivier Saut'
  gem.email = 'osaut@airpost.net'
  gem.homepage = 'http://kesaco.eu'

  # Fichiers et extensions
  gem.files = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  # Dépendances
  gem.add_runtime_dependency 'celluloid'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'yard'

  # Chemins
  gem.require_paths = ["lib"]
end
