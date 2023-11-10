#!/usr/bin/env ruby

if ARGV.empty?
  $stderr.puts "USAGE: #{$0} [REPO]"
  exit 2
end
repo  = ARGV[0]
NPROC = 4 # FIXME: automate


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
def cmakeGen(repo, install)
  exe "cmake -S #{repo} -B #{buildSys repo} -DCMAKE_INSTALL_PREFIX=#{install}"
end
def cmakeBuild(repo)
  exe "cmake --build #{buildSys repo} -j#{NPROC}"
end
def cmakeInstall(repo)
  exe "cmake --install #{buildSys repo}"
end
def cmake(repo, install)
  cmakeGen     repo, install
  cmakeBuild   repo
  cmakeInstall repo
end


# build a repo
case repo
when 'hipo'
  cmake repo, prefix
else
  $stderr.puts "ERROR: unknown repo '#{repo}'"
  exit 1
end
