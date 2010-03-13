# This is a watchr script, http://rubygems.org/gems/watchr

watch('^lib/(.*).rb')         { |m| ruby ["test/unit/#{m[1]}_test.rb"] + edge_to_edge }
watch('^test/.*_test.rb')     { |m| ruby m[0] }
watch('^test/test_helper.rb') { ruby all }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
Signal.trap('QUIT') { ruby all  } # Ctrl-\
Signal.trap('INT' ) { abort("\n") } # Ctrl-C

# --------------------------------------------------
# Helpers
# --------------------------------------------------
def ruby(*paths)
  run "ruby -rvendor/gems/environment -Itest -e'%w(#{paths.flatten.join(' ')}).each {|p| require p }'"
end

def all
  unit + edge_to_edge
end

def edge_to_edge
  Dir['test/edge_to_edge/*_test.rb']
end

def unit
  Dir['test/unit/*_test.rb']
end

def run(cmd)
  puts(clear + cmd)
  system(cmd)
end

# Clear the screen before each run. This way, it's visually easier to parse the
# test output, and I don't have to bend my neck so much.
#
# http://en.wikipedia.org/wiki/ANSI_escape_code#Codes
#   \e[2J clears the entire screen
#   \e[H  positions the cursor at 1,1
def clear
  "\e[2J\e[H"
end

