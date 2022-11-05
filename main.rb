require 'httparty'
require 'json'


def token()
    system("python gettoken.py")
    f = File.open("token.txt")
    token = f.read()
    return token
end

def threechar()
    a = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
    $tracklist = []

    a = a.permutation(3).to_a
    for i in a do
        ign = i.join("")
        $tracklist.push(ign)
    end

    headers = {
        "Authorization": "Bearer #{token}",
        "Content-Type": "application/json"
    }

    token = token()
    available = false

    until available == true
        mojang = true
        gapple = true

        for i in $tracklist do
            starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

            if mojang == true
                puts i
                response = HTTParty.get("https://api.minecraftservices.com/minecraft/profile/name/#{i}/available", headers: headers)
                if response.code == 200
                    data = JSON.parse(response.body)
                    if data.has_value?("AVAILABLE")
                        response = HTTParty.put("https://api.minecraftservices.com/minecraft/profile/name/#{i}", headers: headers)
                        puts response.body
                        available = true
                    end
                elsif response.code == 401
                    puts 'Auth failed'
                    token = token()
                elsif response.code == 429
                    puts 'Too many requests'
                    mojang = false
                    gapple = true
                else
                    puts 'Fail'
                    available = true
                end

            elsif gapple == true
                puts "gapple - #{i}"
                response = HTTParty.get("https://api.gapple.pw/blocked/#{i}", headers: {"Content-Type" => "application/json"})
                data = JSON.parse(response.body)
                if response.code == 200
                    puts response.body
                    if data.has_value?("available")
                        response = HTTParty.put("https://api.minecraftservices.com/minecraft/profile/name/#{i}", headers: headers)
                        puts response.body
                        available = true
                    end
                elsif response.code == 429
                    puts 'gapple - Too many requests'
                    gapple = false
                    mojang = true                    
                end

            end
        end
        ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        elapsed = ending - starting
        puts "looped over all 3 char names in #{elapsed}s"
    end
end

def snipe(ign)
    headers = {
        "Authorization": "Bearer #{token}",
        "Content-Type": "application/json"
    }

    token = token()

    done = false
    gapple = true
    ashcon = true
    until done == true
        count = 0
        50.times{
            response = HTTParty.get("https://api.gapple.pw/blocked/#{ign}", headers: {"Content-Type" => "application/json"})
            data = JSON.parse(response.body)
            if data.has_value?("available")
                response = HTTParty.put("https://api.minecraftservices.com/minecraft/profile/name/#{ign}", headers: headers)
                puts response.body
                done = true
            else
                puts response.body
            end
        }
        token = token()
        response = HTTParty.get("https://api.minecraftservices.com/minecraft/profile/name/#{ign}/available", headers: headers)
        if response.code == 200
            data = JSON.parse(response.body)
            if data.has_value?("AVAILABLE")
                response = HTTParty.put("https://api.minecraftservices.com/minecraft/profile/name/#{ign}", headers: headers)
                puts response.body
                done = true
            end
            puts ('new token')
        end
    end
end
