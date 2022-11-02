require 'http'
require 'json'

a = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
tracklist = []

a = a.permutation(3).to_a
for i in a do
    ign = i.join("")
    tracklist.push(ign)
end

