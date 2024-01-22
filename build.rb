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
def cmakeOpt(key, val)
  "-D#{key}=#{val}"
end
cmakeGen     = Proc.new{ |args=''| exe "cmake -S #{repo} -B #{buildSys repo} --install-prefix=#{prefix} #{args}" }
cmakeBuild   = Proc.new{ exe "cmake --build #{buildSys repo} -j#{ncpu}" }
cmakeInstall = Proc.new{ exe "cmake --install #{buildSys repo}" }
cmake = Proc.new do |argList=[]|
  cmakeGen.call argList.join(' ')
  cmakeBuild.call
  cmakeInstall.call
end


# build a repo
case repo
when 'hipo'
  cmake.call
when 'fmt'
  cmake.call [
    ### can only build either shared or static lib, but not both! ###
    cmakeOpt('CMAKE_POSITION_INDEPENDENT_CODE','TRUE'), # static library
    # cmakeOpt('BUILD_SHARED_LIBS','TRUE'), # shared library
  ]
else
  $stderr.puts "ERROR: unknown repo '#{repo}'"
  exit 1
end
