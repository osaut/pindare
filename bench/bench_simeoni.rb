($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '../lib' ))).uniq!
($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '../example' ))).uniq!

require 'pindare'
require 'benchmark'
require 'tmpdir'
include Benchmark

 Dir.mktmpdir { |dir|
  # On compile l'exécutable
  cpp_exe_name="#{dir}/a.out"
  system "g++ -o #{cpp_exe_name} ./example/model_simeoni.cc"

  n=20
  Benchmark.benchmark(CAPTION, 15, FORMAT, "> Comparison: ") do |x|
    tc=x.report("Cc version") { n.times do system cpp_exe_name end }
    tr=x.report("Ruby version") { n.times do system "ruby", "./example/model_simeoni.rb" end}
    [tr/tc]
  end

}
