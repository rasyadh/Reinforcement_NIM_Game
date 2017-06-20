require 'json'
require 'deep_clone'

def haveChild(data)
    have = false
    for i in 0...data.length
        if data[i] > 2
            have = true
            break
        end
    end
    return have
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
    end
    
    if isPrint == 1
        puts ""
        for i in 0...(data['child']).length
            print "#{(i+1)} . "
            for j in 0...(data['child'][i]['form']).length
                print " #{data['child'][i]['form'][j]}  "
            end
            puts "\t #{data['child'][i]['x']}"
        end
        puts "\nAI memilih langkah ke #{(best_index + 1)}"
    end
    return data['child'][index]
end

def playerTurn(data, win_cond, player)
    puts ""
    for i in 0...(data['child']).length
        print "#{(i+1)} . "
        for j in 0...(data['child'][i]['form']).length
            print " #{data['child'][i]['form'][j]} "
        end
        print "\t #{data['child'][i]['x']}"
    end
    while true do
        print "Player #{player}\nInputkan langkah berikutnya : "
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
                puts "Kondisi saat ini"
                for i in 0...(tmp_data['form']).length
                    print " #{tmp_data['form'][i]} "
                end
                puts ""
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
        puts "Read file #{filename}"
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

while true do
    print "1. Buat Data Baru\n2. Ambil Data dari File\n"
    print "Pilih Sumber Data : "
    mode_data = gets.chomp.to_i
    if [1, 2].include? mode_data
        break
    else
        puts "Input Tidak Valid\n\n"
    end
end
filename = nil
if mode_data == 2
    while true do
        print "Nama File : "
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
        print "Input jumlah batang (5 - 15) : "
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
    puts "Data berhasil dibuat.\nRuntime : #{endt - start} second"
    puts "Data : \n #{data.to_json}"
end

puts "\nNIM GAME"
while true do
    puts "\n1.Human\n2.AI"
    print "Pilih jenis player 1 : "
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
        puts "Input Harus Bertipe Integer"
    end
end

while true do
    puts "\n1.Human\n2.AI"
    print "Pilih jenis player 2 : "
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
        puts "Input Harus Bertipe Integer"
    end
end

if player1 == 2 and player2 == 2
    mode = 1
    explore, jumlah_eksperimen, koef = nil, nil, nil
    output_file = filename
    while true do
        if jumlah_eksperimen == nil
            print "Inputkan jumlah eksperimen : "
            jumlah_eksperimen = gets.chomp
            if CheckInt(jumlah_eksperimen)
                jumlah_eksperimen = jumlah_eksperimen.to_i
                if jumlah_eksperimen < 0
                    puts "Input tidak boleh 0"
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
            print "Inputkan nilai koefisien [0 - 1] : "
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
            print "Input presentase eksplorasi [0 - 1] : "
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
            print "Nama file output : "
            output_file = gets.chomp.to_s
            if output_file == ""
                output_file = nil
                break
            end
        end
        puts "Nak Kene"
        if explore != nil and jumlah_eksperimen != nil and koef != nil and output_file != nil
            break
        end
    end
elsif player1 == 2 or player2 == 2
    mode = 2
    jumlah_eksperimen, koef, learn_again, learn, explore, koef_awal, explore_awal = nil, nil, nil, nil, nil, nil, nil
    output_file = filename
    while true do
        if learn == nil
            print "AI melakukan pembelajaran [Y/N] : "
            learn = gets.chomp
            unless ["Y", "y", "N", "n"].include? learn
                puts "Input tidak valid"
                learn = nil
                next
            else
                if ["N","n"].include? learn
                    jumlah_eksperimen_awal = 1
                    koef_awal, explore_awal = 0, 0
                end
            end
        end
        if jumlah_eksperimen == nil and (["Y",'y'].include? learn or ["Y","y"].include? learn_again)
            puts "Inputkan jumlah eksperimen : "
            jumlah_eksperimen = gets.chomp
            if CheckInt(jumlah_eksperimen)
                jumlah_eksperimen = jumlah_eksperimen.to_i
                if jumlah_eksperimen < 0
                    puts "Input harus berupa bilangan positf"
                    jumlah_eksperimen = nil
                    next
                end
            else
                puts "Input harus bertipe Integer"
                jumlah_eksperimen = nil
                next
            end
        end
        if koef == nil and (["Y",'y'].include? learn or ["Y","y"].include? learn_again)
            print "Input nilai koefisien [0 - 1] : "
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
            print "Input presentase eksplorasi [0 - 1] : "
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
        if learn_again == nil
            puts "AI tetap melakukan pembelajaran saat melawan user [Y/N] : "
            learn_again = gets.chomp
            unless ["Y","y","N","n"].include? learn_again
                puts "Input tidak sesuai"
                learn_again = nil
                next
            end
        end
        if learn != nil and learn_again != nil
            if jumlah_eksperimen == nil
                jumlah_eksperimen = jumlah_eksperimen_awal
            end
            if explore == nil
                explore = 0
            end
            if koef == nil
                koef = koef_awal
            end
            if explore_awal == nil
                explore_awal = explore
            end
            if koef_awal == nil
                koef_awal = koef
            end
            break
        end
    end
else
    mode = 2
    jumlah_eksperimen = 1
    koef, output_file = nil, nil
    explore = 0
end

if jumlah_eksperimen > 1 and mode == 2
    start = Time.now
    play(data, explore_awal, jumlah_eksperimen, koef_awal, 2, 2, 0)
    endt = Time.now
    while true do
        puts data.to_json
        puts "Data berhasil di simpan.\nRuntime : #{endt - start} second"
        pemenang = play(data, 0, 1, koef, player1, player2, 1)
        puts "GAME OVER"
        if pemenang == 1
            pemenang_s = player1s
        else
            pemenang_s = player2s
        end
        puts "Pemenang adalah player #{pemenang} : #{pemenang_s}"
        while true do
            print "Main lagi [Y/N] : "
            lagi = gets.chomp
            if ["Y","y","N","n"].include? lagi
                break
            else
                puts "Input tidak sesuai"
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
    