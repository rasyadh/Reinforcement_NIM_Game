require 'deep_clone'

def CheckInt(s)
    begin
        Integer s
        return true
    rescue
        return false
    end
end

def CheckFloat(s)
    begin
        Float s
        return true
    rescue
        return false
    end
end

start = Time.now
puts CheckInt(1.5)
puts CheckFloat(5)
endt = Time.now
puts start - endt

arr = [3,5,4,1,6]
app = DeepClone.clone(arr)
puts app

puts ""
puts rand(0.0..1.0)

explore, jumlah_eksperimen, koef = 1
puts explore, jumlah_eksperimen, koef