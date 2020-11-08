
puts "loading up the assert lib"

class AssertFailed < RuntimeError

end

def assert &block 
  raise AssertFailed unless yield
end

