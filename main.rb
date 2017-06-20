require 'json'
require 'deep_clone'

def haveChild(data)
    child = false
    for i in 0...data.length
        if data[i] > 2
            child = true
            break
        end
    end
    return child
end

def setChild(form, status)
    ret = []
    if status == 0
        status = 1
    else
        status = 0
    end
    sibling_form = []
    for i in 0...form.length
        for j in 0...(form[i]/2).to_i
            tmp_form = DeepClone.clone(form)
            tmp_data = {}
            if tmp_form[i] - (j+1) == (j+1)
                next
            else
                tmp_form.push(j+1)
                tmp_form.push(tmp_form[i] - (j+1))
                tmp_form.delete_at(i)
                tmp_form.sort!.reverse!
                unless tmp_form.include? sibling_form
                    sibling_form.push(tmp_form)
                    if haveChild(tmp_form)
                        tmp_data['x'] = 0.5
                    else
                        tmp_data['x'] = status
                    end
                    tmp_data['form'] = DeepClone.clone(tmp_form)
                    tmp_data['child'] = setChild(tmp_form, status)
                    ret.push(tmp_data)
                end
            end
        end
    end
    return ret
end

def createNimData(jumlah_batang)
    tmp_data = {}
    form = []
    form.push(jumlah_batang)
    tmp_data['form'] = form
    tmp_data['x'] = 0.5
    tmp_data['child'] = setChild(form, 0)
    return tmp_data
end

def aiTurn(data, win_cond, explore, koef, isPrint)
    index = 0
    if rand(0.0..1.0) <= explore
        index = rand(0..((data['child']).length-1))
        data['x'] = data['x'] + koef * (data['child'][index]['x'] - data['x'])
    else
        best_index = 0
        for i in 0...(data['child']).length
            if i == 0
                best_index = i
            else
                if win_cond == 1
                    if data['child'][i]['x'] > data['child'][best_index]['x']
                        best_index = i
                    end
                else
                    if data['child'][i]['x'] < data['child'][best_index]['x']
                        best_index = i
                    end
                end
            end
        end
        index = best_index
    end
    
    if isPrint == 1
        puts ""
        for i in 0...(data['child']).length
            print "#{(i+1)}) "
            for j in 0...(data['child'][i]['form']).length
                print " #{data['child'][i]['form'][j]}  "
            end
            puts "\t| #{data['child'][i]['x']}"
        end
        puts "\nAI memilih langkah ke #{(best_index + 1)}"
    end
    return data['child'][index]
end

def playerTurn(data, win_cond, player)
    puts ""
    for i in 0...(data['child']).length
        print "#{(i+1)}) "
        for j in 0...(data['child'][i]['form']).length
            print " #{data['child'][i]['form'][j]} "
        end
        puts "\t| #{data['child'][i]['x']}"
    end
    while true do
        print "\nPlayer #{player} | Input langkah berikutnya = "
        pilihan = gets.chomp
        if CheckInt(pilihan)
            pilihan = pilihan.to_i
            if pilihan < 1 or pilihan > data['child'].length
                puts "Input tidak sesuai"
            else
                break
            end
        else
            puts "Input harus bertipe Integer"
        end
    end
    return data['child'][pilihan-1]
end

def play(data, explore, jumlah_main, koef, player1, player2, isPrint)
    turn = 1
    mainke = 1
    while jumlah_main >= mainke
        tmp_data = data
        while tmp_data['child'].length > 0
            if isPrint == 1
                print "\nJumlah batang saat ini = "
                for i in 0...(tmp_data['form']).length
                    print "#{tmp_data['form'][i]} "
                end
                print "\n-------------------------"
            end
            if turn == 1
                if player1 == 1
                    tmp_data = playerTurn(tmp_data, 1, 1)
                else
                    tmp_data = aiTurn(tmp_data, 1, explore, koef, isPrint)
                end
                turn = 2
            else
                if player2 == 1
                    tmp_data = playerTurn(tmp_data, 0, 2)
                else
                    tmp_data = aiTurn(tmp_data, 0, explore, koef, isPrint)
                end
                turn = 1
            end
        end
        mainke += 1
    end
    if turn == 2
        return 1
    else
        return 2
    end
end

def readFile(filename)
    file_content = "{}"
    begin
        file = File.open(filename, "r")
        file_content = file.read
        puts "\nData file #{filename} = "
        unless file_content
            puts "Tidak ada data dalam file #{filename}"
        end
    rescue
        
    end
    return file_content
end

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

puts "Reinforcement Learning\n-------------------------"
while true do
    print "1. Buat Data Baru\n2. Ambil Data dari File\n"
    print "Pilih Sumber Data : "
    mode_data = gets.chomp.to_i
    if [1, 2].include? mode_data
        break
    else
        puts "Input tidak valid"
    end
end
filename = nil
if mode_data == 2
    while true do
        print "\nNama file yang diload : "
        filename = gets.chomp.to_s
        dataJson = readFile(filename)
        data = JSON.parse(dataJson)
        puts dataJson
        if data.length < 1
            puts "Data tidak valid"
        else
            break
        end
    end
else
    while true do
        print "\nInput jumlah batang (5-15) : "
        jml_batang = gets.chomp
        if CheckInt(jml_batang)
            jumlah_batang = jml_batang.to_i
            if jumlah_batang < 5 or jumlah_batang > 15
                puts "Input tidak sesuai batasan"
            else
                break
            end
        else
            puts "Input harus bertipe Integer"
        end
    end
    start = Time.now
    data = createNimData(jumlah_batang)
    endt = Time.now
    puts "Data berhasil dibuat.\nRuntime = #{endt - start} second"
    puts "\nData : \n #{data.to_json}"
end

puts "\nNIM GAME\n-------------------"
while true do
    puts "Player 1\n1.Human\n2.AI"
    print "Pilih jenis player 1 = "
    player1 = gets.chomp
    if CheckInt(player1)
        player1 = player1.to_i
        unless [1,2].include? player1
            puts "Input tidak valid"
        else
            if player1 == 1
                player1s = "Human"
            else
                player1s = "AI"
            end
            break
        end
    else
        puts "Input harus bertipe Integer"
    end
end
puts ""
while true do
    puts "Player 2\n1.Human\n2.AI"
    print "Pilih jenis player 2 = "
    player2 = gets.chomp
    if CheckInt(player2)
        player2 = player2.to_i
        unless [1,2].include? player2
            puts "Input tidak valid"
        else
            if player2 == 1
                player2s = "Human"
            else
                player2s = "AI"
            end
            break
        end
    else
        puts "Input harus bertipe Integer"
    end
end

if player1 == 2 and player2 == 2
    mode = 1
    explore, jumlah_eksperimen, koef = nil, nil, nil
    output_file = filename
    jumlah_eksperimen_awal = 0
    while true do
        if jumlah_eksperimen == nil
            print "\nInput jumlah eksperimen = "
            jumlah_eksperimen = gets.chomp
            if CheckInt(jumlah_eksperimen)
                jumlah_eksperimen = jumlah_eksperimen.to_i
                if jumlah_eksperimen < 0
                    puts "Input harus bilangan positif"
                    jumlah_eksperimen = nil
                    next
                end
            else
                puts "Input harus bertipe Integer"
                jumlah_eksperimen = nil
                next
            end
        end
        if koef == nil
            print "Inputkan nilai koefisien [0-1] = "
            koef = gets.chomp
            if CheckFloat(koef)
                koef = koef.to_f
                if koef < 0 or koef > 1
                    puts "Input melebihi atau kurang dari batas range"
                    koef = nil
                    next
                end
            else
                puts "Input harus bertipe float"
                koef = nil
                next
            end
        end
        if explore == nil
            print "Input presentase eksplorasi [0-1] = "
            explore = gets.chomp
            if CheckFloat(explore)
                explore = explore.to_f
                if explore < 0 or explore > 1
                    puts "Input melebihi atau kurang dari batas range"
                    explore = nil
                    next
                end
            else
                puts "Input harus bertipe float"
                explore = nil
                next
            end
        end
        if output_file == nil
            print "Nama file output = "
            output_file = gets.chomp.to_s
            if output_file == ""
                output_file = nil
                break
            end
        end
        if explore != nil and jumlah_eksperimen != nil and koef != nil and output_file != nil
            break
        end
    end
elsif (player1 == 2 or player2 == 2) and mode_data == 1
    mode = 2
    jumlah_eksperimen_awal, koef, learn_again, learn, explore, explore_next = nil, nil, nil, nil, nil, nil
    output_file = filename
    while true do
        if learn == nil
            print "AI melakukan pembelajaran sebelum bermain [Y/N] = "
            learn = gets.chomp
            unless ["Y", "y", "N", "n"].include? learn
                puts "Input tidak valid"
                learn = nil
                next
            else
                if ["N","n"].include? learn
                    jumlah_eksperimen_awal = 0
                    koef_awal, explore_awal = 0, 0
                end
            end
        end
        if jumlah_eksperimen_awal == nil and (["Y",'y'].include? learn or ["Y","y"].include? learn_again)
            puts "Input jumlah eksperimen = "
            jumlah_eksperimen_awal = gets.chomp
            if CheckInt(jumlah_eksperimen_awal)
                jumlah_eksperimen_awal = jumlah_eksperimen_awal.to_i
                if jumlah_eksperimen_awal < 0
                    puts "Input harus berupa bilangan positf"
                    jumlah_eksperimen_awal = nil
                    next
                end
            else
                puts "Input harus bertipe Integer"
                jumlah_eksperimen_awal = nil
                next
            end
        end
        if koef == nil and (["Y",'y'].include? learn or ["Y","y"].include? learn_again)
            print "Input nilai koefisien [0-1] = "
            koef = gets.chomp
            if CheckFloat(koef)
                koef = koef.to_f
                if koef < 0 or koef > 1
                    puts "Input melebihi atau kurang dari range"
                    koef = nil
                    next
                end
            else
                puts "Input haus bertipe float"
                koef = nil
                next
            end
        end
        if explore == nil and (["Y",'y'].include? learn or ["Y","y"].include? learn_again)
            print "Input presentase eksplorasi [0-1] = "
            explore = gets.chomp
            if CheckFloat(explore)
                explore = explore.to_f
                if explore < 0 or explore > 1
                    puts "Input melebihi atau kurang dari range"
                    explore = nil
                    next
                end
            end
        end
        if learn != nil and jumlah_eksperimen != nil and koef != nil and explore != nil
            break
        end
    end

    while true do
        learn_again, explore_next = nil, nil
        if learn_again == nil
            print "\nAI melakukan pembelajaran saat bermain [Y/N] = "
            learn_again = gets.chomp
            if ["Y","y","N","n"].include? learn_again
                puts "Input tidak valid"
                learn_again = nil
                next
            else
                if ["Y","y"].include? learn_again
                    if explore_next == nil and (["Y","y"].include? learn or ["Y","y"].include? learn_again)
                        print "Input presentase eksplorasi saat bermain [0-1] = "
                        explore_next = gets.chomp
                        if CheckFloat(explore_next)
                            explore_next = explore_next.to_f
                            if explore_next < 0 or explore_next > 1
                                puts "Input melebihi atau kurang dari range"
                                explore_next = nil
                                learn_again = nil
                                next
                            end
                        end
                    end
                else
                    explore_next = 0
                end
            end
        end
        if learn_again != nil and explore_next != nil
            break
        end
    end
else
    mode = 2
    jumlah_eksperimen, jumlah_eksperimen_awal = 1, 1
    koef, output_file = nil, nil
    explore, explore_next = 0, 0
end

if jumlah_eksperimen > 1 and mode == 2
    start = Time.now
    play(data, explore, jumlah_eksperimen_awal, koef, 2, 2, 0)
    endt = Time.now
    puts "Data berhasil disimpan.\nRuntime = #{endt - start} second"
end
if mode == 2
    while true do
        puts data.to_json
        pemenang = play(data, explore_next, 1, koef, player1, player2, 1)
        puts "\nGame Selesai"
        if pemenang == 1
            pemenang_s = player1s
        else
            pemenang_s = player2s
        end
        puts "Pemenang player#{pemenang} = #{pemenang_s}"
        while true do
            print "\nMain lagi [Y/N] = "
            lagi = gets.chomp
            if ["Y","y","N","n"].include? lagi
                break
            else
                puts "Input tidak valid"
            end
        end
        if ["Y","y"].include? lagi
            next
        else
            break
        end
    end
elsif mode == 1
    play(data, explore,jumlah_eksperimen, koef, player1, player2, 0)
end

if output_file != nil
    $stdout = File.new(output_file, "w")
    puts data.to_json
    $stdout.sync = true
end
    