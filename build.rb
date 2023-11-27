#!/usr/bin/env ruby

ncpu = `nproc`.chomp
if ARGV.empty?
  $stderr.puts "USAGE: #{$0} [REPO] [NCPU(def=#{ncpu})]"
  exit 2
end
repo = ARGV[0]
ncpu = ARGV[1] if ARGV.length > 1

# set prefix
prefix = "#{Dir.pwd}/install"

# set build system
def buildSys(repo)
  "#{repo}/build"
end

# print then run a command
def exe(cmd)
  puts "[+] #{cmd}"
  system cmd or raise "FAILED: #{cmd}"
end


# cmake commands
cmakeGen = Proc.new do |repo, install|
  exe "cmake -S #{repo} -B #{buildSys repo} -DCMAKE_INSTALL_PREFIX=#{install}"
end
cmakeBuild = Proc.new do |repo|
  exe "cmake --build #{buildSys repo} -- -j#{ncpu}"
end
cmakeInstall = Proc.new do |repo|
  exe "cmake --install #{buildSys repo}"
end
cmake = Proc.new do |repo, install|
  cmakeGen.call     repo, install
  cmakeBuild.call   repo
  cmakeInstall.call repo
end


# build a repo
case repo
when 'hipo'
  cmake.call repo, prefix
else
  $stderr.puts "ERROR: unknown repo '#{repo}'"
  exit 1
end
