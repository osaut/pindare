Gem::Specification.new do |s|
  # Infos de base / version
  s.name = 'pindare'
  s.version = '0.0.1'
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
  s.files = Dir['lib/**/*.rb']
  s.test_files = Dir.glob('test/*_test.rb')

  # Dépendances
  gem 'celluloid'
  gem 'ruby-progressbar'

  # Chemins
  #s.require_path='.'
end
