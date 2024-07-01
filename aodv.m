filename = 'Hsimulasicut.xlsx';
sheet = 'Sheet2';
data = readtable(filename, 'Sheet', sheet);

t = data.time;
x = data.x;
y = data.y;
l = data.lane;
p = data.type;
a = data.angle;
s = data.speed;
r = data.id;

K = 30; % Konstanta berbeda setiap lingkungan

% start1 = 11;

figure; % Membuat figure baru

Data_t = unique(t);
Data_p = unique(p);
Data_l = unique(l);

% Inisialisasi variabel baru dengan zeros
selectedData = zeros(80, 3);

% Mengambil 80 baris pertama dari kolom x, y, dan id
selectedData(:, 1) = data.x(1:80);
selectedData(:, 2) = data.y(1:80);

% Mengambil angka setelah karakter 'f_'
id = str2double(extractAfter(data.id(1:80), 'f_'));

% Mengisi kolom ketiga dari newVariable dengan data numerik
selectedData(:, 3) = id;

% Inisialisasi indeks t
t = 1;

% Maksimum iterasi yang diinginkan
maxIterations = height(data); 

% Inisialisasi tabel untuk menyimpan hasil
result = table('Size', [80, 6], ...
    'VariableTypes', {'double', 'double', 'string', 'double', 'double', 'string'}, ...
    'VariableNames', {'t', 'd', 'id', 'x', 'y', 'sequence'});


% Membuat loop untuk mengisi variable result
while t + 1 <= maxIterations 
    % Increment t
    t = t + 1;

    % Kalkulasi nilai d hanya untuk titik tertentu
    d = sqrt((data.x(t) - data.x(t-1)).^2 + (data.y(t) - data.y(t-1)).^2);

    % Menyimpan nilai t, d, id, x, dan y ke dalam result
    result.t(t) = data.time(t);
    result.d(t) = d;
    result.id{t} = data.id{t};
    result.x(t) = data.x(t);
    result.y(t) = data.y(t);
end

% Filter hasil result untuk menghilangkan data dengan t = 0
result = result(result.t > 0, :);

% Inisialisasi variabel baru untuk menyimpan data
group = table('Size', [100, 1], ...
    'VariableTypes', {'cell'}, ...
    'VariableNames', {'Result'});

% Menggabungkan data t dan id menjadi data baru 'sequence' di tabel result
result.sequence = strcat(string(result.id), '_', string(result.t));

% Inisialisasi struktur untuk menyimpan jumlah kemunculan setiap ID pada setiap iterasi
id_counts = containers.Map('KeyType', 'char', 'ValueType', 'double');

% Membuat loop untuk mengecek setiap nilai t
for t = 1:max(result.t)
    % Mendapatkan ID yang muncul pada iterasi saat ini
    ids_current = unique(result.id(result.t == t));
    
    % Loop melalui setiap ID yang muncul pada iterasi saat ini
    for id_idx = 1:numel(ids_current)
        id = ids_current{id_idx};
        % Jika ID tidak ada dalam struktur id_counts, tambahkan dan atur nilai awalnya menjadi 0
        if ~isKey(id_counts, id)
            id_counts(id) = 0;
        end
        % Mendapatkan jumlah kemunculan ID pada iterasi sebelumnya
        count_prev = id_counts(id);
        
        % Mendapatkan indeks ID pada iterasi saat ini
        idx_current = find(strcmp(result.id, id) & result.t == t);
        
        % Memperbarui sequence untuk ID pada iterasi saat ini dengan indeks unik yang tepat
        for i = 1:numel(idx_current)
            result.sequence{idx_current(i)} = [id, '_', num2str(count_prev + i)];
        end
        
        % Mengupdate jumlah kemunculan ID
        id_counts(id) = count_prev + numel(idx_current);
    end
end

% Iterasi untuk t = 1 hingga 100
for t = 1:100
    % Mengambil data dengan nilai 't' sesuai iterasi
    resultTable = result(result.t == t, :);

    % Perhitungan nilai d
    if t > 1
        d = sqrt((data.x(t) - data.x(t-1)).^2 + (data.y(t) - data.y(t-1)).^2);
    else
        d = 0; 
    end
    
    % Jika data tidak mencapai 80 baris, tambahkan baris dengan nilai 0
    if size(resultTable, 1) < 80
        rowsTotal = 80 - size(resultTable, 1);
        rowsZero = array2table(zeros(rowsTotal, width(resultTable)), 'VariableNames', resultTable.Properties.VariableNames);
        resultTable = [resultTable; rowsZero];
    end

    % Simpan resultTime ke dalam group
    group.Result{t} = resultTable;

    % Hapus variabel yang tidak ingin ditampilkan di workspace
    clear nonZeroDIdx rowsTotal rowsZero;
end

% Iterasi untuk t = 1 hingga 100
for t = 1:100
    % Mengambil tabel dari dalam cell array
    resultTableTime = group.Result{t};

    % Menambahkan kolom warna ke dalam tabel hanya jika d > 0
    resultTableTime.color = cell(height(resultTableTime), 1);

    % Temukan indeks baris dengan nilai d terkecil
    minD = find(resultTableTime.d == min(resultTableTime.d(resultTableTime.d > 0)), 1, 'first');

    % Berikan warna hijau untuk nilai d terkecil jika d > 0
    if ~isempty(minD)
        resultTableTime.color{minD} = 'green';
    end

    % Isi nilai biru hanya untuk baris dengan nilai d sama dengan 0
    zeroDIdx = resultTableTime.d == 0;
    
    % Hapus node biru dengan nilai d = 0 dari hasil plot
    resultTableTime(zeroDIdx, :) = [];
    
    % Isi nilai biru untuk baris dengan nilai d tidak sama dengan 0 dan tidak memiliki warna
    nonZeroDIdx = find(resultTableTime.d > 0 & cellfun('isempty', resultTableTime.color));
    resultTableTime.color(nonZeroDIdx) = {'blue'};

    % Menyimpan indeks baris dengan nilai d terkecil sebagai Head Cluster (warna hijau)
    headClusterIdx = find(strcmp(resultTableTime.color, 'green'));
    if ~isempty(headClusterIdx)
        resultTableTime.color{headClusterIdx} = 'Head Cluster';
    end

    % Menghasilkan nilai pt dalam rentang [200, 300] berdasarkan t
    pt = 50 + (t - 1) * 10; % Pertambahan 10 setiap iterasi t
    
    % Pastikan pt tidak melebihi 300
    if pt > 100
        pt = 100;
    end
    
    % Membuat kolom pt untuk setiap baris
    resultTableTime.pt = repmat(pt, height(resultTableTime), 1);
    
%     % Menghasilkan nilai rt dalam rentang [1, 40] berdasarkan t
%     rt = 1 + (t - 1) * 1; % Pertambahan 1 setiap iterasi t
%     
%     % Pastikan rt tidak melebihi 40
%     if rt > 40
%         rt = 40;
%     end
%     
%     % Membuat kolom rt untuk setiap baris
%     resultTableTime.rt = repmat(rt, height(resultTableTime), 1);

%     % Menghasilkan nilai acak untuk pt dalam rentang [200, 300]
%     pt = randi([200, 300], height(resultTableTime), 1);
%     
    % Mengatur semua nilai dalam rt menjadi 40
    rt = repmat(20, height(resultTableTime), 1);
%     
%     % Mengassign nilai yang dihasilkan ke kolom yang sesuai dalam resultTableTime
%     resultTableTime.pt = pt;
    resultTableTime.rt = rt;

    % Menyimpan tabel yang telah dimodifikasi ke dalam cell array
    group.Result{t} = resultTableTime;

    % Hapus variabel yang tidak ingin ditampilkan di workspace
    clear nonZeroDIdx zeroDIdx;
    clear headClusterIdx;
end

% Iterasi untuk t = 1 hingga 100
for t = 1:100
    % Mengambil tabel dari dalam cell array
    resulttime = group.Result{t};

    % Menambahkan kolom warna ke dalam tabel hanya jika d > 0
    resulttime.color = cell(height(resulttime), 1);

    % Temukan indeks baris dengan nilai d terkecil dan terbesar
    minD = find(resulttime.d == min(resulttime.d(resulttime.d > 0)), 1, 'first');
    maxD = find(resulttime.d >= 300);

    % Berikan warna hijau untuk nilai d terkecil jika d > 0
    if ~isempty(minD)
        resulttime.color{minD} = 'green';
    end

    % Berikan warna merah untuk nilai d lebih besar atau sama dengan 300
    if ~isempty(maxD)
        resulttime.color(maxD) = {'red'};
    end
    
    % Isi nilai biru hanya untuk baris dengan nilai d sama dengan 0
    zeroDIdx = resulttime.d == 0;
    
    % Hapus node biru dengan nilai d = 0 dari hasil plot
    resulttime(zeroDIdx, :) = [];
    
    % Isi nilai biru untuk baris dengan nilai d tidak sama dengan 0 dan tidak memiliki warna
    nonZeroDIdx = find(resulttime.d > 0 & cellfun('isempty', resulttime.color));
    resulttime.color(nonZeroDIdx) = {'blue'};

    % Menyimpan indeks baris dengan nilai d terkecil sebagai Head Cluster (warna hijau)
    headClusterIdx = find(strcmp(resulttime.color, 'green'));
    if ~isempty(headClusterIdx)
        resulttime.color{headClusterIdx} = 'Head Cluster';
    end

    % Inisialisasi matriks koneksi
    resulttime.koneksi = zeros(size(resulttime, 1), size(resulttime, 1));
    
    % Nonaktifkan koneksi ke node-node merah
    redNodesIdx = find(strcmp(resulttime.color, 'red'));
    if ~isempty(redNodesIdx)
        for i = 1:length(redNodesIdx)
            redNode = redNodesIdx(i);
            resulttime.koneksi(redNode, :) = 0; % Nonaktifkan koneksi ke node lain
            resulttime.koneksi(:, redNode) = 0; % Nonaktifkan koneksi dari node lain
        end
    end
    
    % Mendapatkan indeks node yang belum terkoneksi
    unconnectedNodesIdx = find(sum(resulttime.koneksi, 2) == 0);
    
    % Urutkan node yang belum terkoneksi berdasarkan nilai d dari terkecil hingga terbesar
    [~, sortedIdx] = sort(resulttime.d(unconnectedNodesIdx));
    sortedUnconnectedNodesIdx = unconnectedNodesIdx(sortedIdx);
    
    % Membuat koneksi ulang berdasarkan node yang tidak terkoneksi yang sudah diurutkan
    for i = 1:length(sortedUnconnectedNodesIdx)
        currentNode = sortedUnconnectedNodesIdx(i);
        for j = (i+1):length(sortedUnconnectedNodesIdx)
            nextNode = sortedUnconnectedNodesIdx(j);
            if resulttime.d(nextNode) < 300 % Jika jarak antara node saat ini dengan node berikutnya kurang dari 300
                resulttime.koneksi(currentNode, nextNode) = 1;
                resulttime.koneksi(nextNode, currentNode) = 1;
                break; % Hanya satu koneksi yang perlu ditambahkan
            end
        end
    end

    % Menghasilkan nilai pt dalam rentang [200, 300] berdasarkan t
    pt = 50 + (t - 1) * 10; % Pertambahan 10 setiap iterasi t
    
    % Pastikan pt tidak melebihi 300
    if pt > 100
        pt = 100;
    end
    
    % Membuat kolom pt untuk setiap baris
    resulttime.pt = repmat(pt, height(resulttime), 1);

%     % Membuat kolom pt untuk setiap baris
%     resulttime.pt = repmat(pt, height(resulttime), 1) + randi([-10, 10], height(resulttime), 1); % Menambahkan variasi acak
    
%     % Mengatur semua nilai dalam rt menjadi 40
%     rt = repmat(40, height(resulttime), 1) + randi([-5, 5], height(resulttime), 1); % Menambahkan variasi acak
%     resulttime.rt = rt;
%     
%     % Menghasilkan nilai rt dalam rentang [1, 40] berdasarkan t
%     rt = 1 + (t - 1) * 1; % Pertambahan 1 setiap iterasi t
%     
%     % Pastikan rt tidak melebihi 40
%     if rt > 40
%         rt = 40;
%     end
%     
%     % Membuat kolom rt untuk setiap baris
%     resulttime.rt = repmat(rt, height(resulttime), 1);

%     % Menghasilkan nilai acak untuk pt dalam rentang [200, 300]
%     pt = randi([200, 300], height(resulttime), 1);
%     
    % Mengatur semua nilai dalam rt menjadi 40
    rt = repmat(10, height(resulttime), 1);
%     
%     % Mengassign nilai yang dihasilkan ke kolom yang sesuai dalam resulttime
%     resulttime.pt = pt;
    resulttime.rt = rt;

    % Set pt dan rt menjadi 0 untuk node yang memiliki warna merah
    if ~isempty(redNodesIdx)
        for i = 1:length(redNodesIdx)
            redNode = redNodesIdx(i);
            resulttime.pt(redNode, :) = 0;
            resulttime.rt(redNode, :) = 0;
        end
    end

    % Menyimpan tabel yang telah dimodifikasi ke dalam cell array
    group.ResultTime{t} = resulttime;

    % Hapus variabel yang tidak ingin ditampilkan di workspace
    clear nonZeroDIdx zeroDIdx;
    clear headClusterIdx maxD minD;
end

% Inisialisasi warna untuk plotting
warna = {'blue', 'red', 'green', 'black', 'cyan', 'magenta', 'yellow', 'white'};

% Inisialisasi delay dan throughput
delay1 = zeros(1, 100);
throughput1 = zeros(1, 100);

% Inisialisasi delay dan throughput
delay2 = zeros(1, 100);
throughput2 = zeros(1, 100);

% Membuat plot untuk setiap nilai t dari 1 hingga 40
for t_idx = 1:20
    % Mengambil tabel dari dalam cell array untuk plot kedua
    resulttime = group.ResultTime{t_idx};

    % Hitung jumlah node merah
    redNodeCount = sum(strcmp(resulttime.color, 'red'));

    % Membersihkan figur pertama sebelum memplot iterasi berikutnya
    figure(1);
    clf;
    axis([-50 350 -40 120]);
%     title('Jalur PKU - Node Kendaraan & Head Cluster');
    title(['Simulasi 1 Tanpa Serangan - Iterasi ', num2str(t_idx)]);
    xlabel('Data x');
    ylabel('Data y');
    grid on;
    hold on;

    % Membersihkan figur kedua sebelum memplot iterasi berikutnya
    figure(2);
    clf;
    axis([-50 350 -40 120]);
%     title(['Jalur PKU - Node Kendaraan & Malicious - Iterasi ', num2str(t_idx)]);
    title(['Simulasi 2 Serangan - Iterasi ', num2str(t_idx), ' - Malicious Nodes: ', num2str(redNodeCount)]);
    xlabel('Data x');
    ylabel('Data y');
    grid on;
    hold on;

    % Membersihkan figur delay sebelum memplot iterasi berikutnya
    figure(3);
    axis('auto');
%     title('Delay');
    xlabel('Jumlah Kendaraan (s)');
    ylabel('Delay (ms)');
    grid on;
    hold on;

    % Membersihkan figur throughput sebelum memplot iterasi berikutnya
    figure(4);
    axis('auto');
%     title('Throughput');
    xlabel('Jumlah Kendaraan (s)');
    ylabel('Throughput (kbps)');
    grid on;
    hold on;

    % Mengambil tabel dari dalam cell array untuk plot pertama
    resultTableTime = group.Result{t_idx};

    for i = 1:size(resultTableTime, 1)        
        if strcmp(resultTableTime.color{i}, 'Head Cluster')
            figure(1);
            scatter(resultTableTime.x(i), resultTableTime.y(i), 100, 'green', 'X', 'LineWidth', 1.5); % Simbol X untuk Head Cluster
        elseif strcmp(resultTableTime.color{i}, 'blue')
            figure(1);
            scatter(resultTableTime.x(i), resultTableTime.y(i), 64, 'blue', 'o', 'filled'); % Titik-titik biru
        end
        
        % Plot garis antar node
        if i < size(resultTableTime, 1)
            figure(1);
            plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
        end
    end

    % Menambahkan legenda untuk figure pertama
    figure(1);
    hold on; 
    h1 = scatter(NaN, NaN, 100, 'green', 'X', 'LineWidth', 1.5); 
    h2 = scatter(NaN, NaN, 64, 'blue', 'o', 'filled'); 
    leg1 = legend([h1, h2], 'Head Cluster', 'Node Kendaraan', 'Location', 'northeast');
    set(leg1, 'Box', 'on');
    hold off; 

    % Mengambil tabel dari dalam cell array untuk plot kedua
    resulttime = group.ResultTime{t_idx};

    % Plot data pada figure kedua
    % Tentukan indeks head cluster di grafik pertama
    originalHeadClusterIndex = find(strcmp(group.ResultTime{1}.color, 'Head Cluster'));
    % Tentukan indeks head cluster di grafik kedua
    newHeadClusterIndex = mod(originalHeadClusterIndex + t_idx - 1, size(resulttime, 1)) + 1;
    % Tentukan node yang ditinggalkan oleh head cluster
    nodesDitinggalkan = originalHeadClusterIndex(originalHeadClusterIndex ~= newHeadClusterIndex);

    for i = 1:size(resulttime, 1)
        if i == newHeadClusterIndex
            figure(2);
            scatter(resulttime.x(i), resulttime.y(i), 100, 'g', 'X', 'LineWidth', 1.5);
        elseif strcmp(resulttime.color{i}, 'red') || strcmp(resulttime.color{i}, 'Malicious')
            figure(2);
            scatter(resulttime.x(i), resulttime.y(i), 64, 'r', 'filled'); 
        elseif ~any(i == nodesDitinggalkan)
            figure(2);
            scatter(resulttime.x(i), resulttime.y(i), 64, 'b', 'filled');
        else
            figure(2);
            scatter(resulttime.x(i), resulttime.y(i), 64, 'b', 'filled');
        end

        % Menggambar koneksi antar node
        for i = 1:size(resulttime.koneksi, 1)
            for j = i+1:size(resulttime.koneksi, 2)
                if resulttime.koneksi(i, j) == 1 && ~strcmp(resulttime.color{i}, 'red') && ~strcmp(resulttime.color{j}, 'red')
                    figure(2);
                    plot([resulttime.x(i), resulttime.x(j)], [resulttime.y(i), resulttime.y(j)], 'b--', 'LineWidth', 1);
                end
            end
        end
    end

    % Menambahkan legenda untuk figure kedua
    figure(2);
    hold on; 
    h1 = scatter(NaN, NaN, 100, 'green', 'X', 'LineWidth', 1.5); 
    h2 = scatter(NaN, NaN, 64, 'blue', 'o', 'filled');
    h3 = scatter(NaN, NaN, 64, 'red', 'o', 'filled');
    leg2 = legend([h1, h2, h3], 'Head Cluster', 'Node Kendaraan', 'Malicious', 'Location', 'northeast');
    set(leg2, 'Box', 'on');
    hold off; 

    % Perhitungan delay dan throughput pada detik t_idx untuk group.Result
    total_pt_1 = sum(group.Result{t_idx}.pt);
    total_rt_1 = sum(group.Result{t_idx}.rt);
%     Delay1 = total_pt_1 / max(total_rt_1, 1);
    Delay1 = total_pt_1 / total_rt_1;
    
    % Perhitungan throughput pada detik t_idx untuk group.Result
    paket_diterima_1 = group.Result{t_idx}.rt; % paket data yang diterima dalam kb
    waktu_pengiriman_1 = group.Result{t_idx}.pt; % waktu pengiriman dalam detik
    Throughput1 = paket_diterima_1 ./ max(waktu_pengiriman_1, 1);
    
    % Perhitungan delay pada detik t_idx untuk group.ResultTime
    total_pt_2 = sum(group.ResultTime{t_idx}.pt);
    total_rt_2 = sum(group.ResultTime{t_idx}.rt);
%     Delay2 = total_pt_2 / max(total_rt_2, 1);
    Delay2 = total_pt_2 / total_rt_2;
    
    % Perhitungan throughput pada detik t_idx untuk group.ResultTime
    paket_diterima_2 = group.ResultTime{t_idx}.rt; % paket data yang diterima dalam kb
    waktu_pengiriman_2 = group.ResultTime{t_idx}.pt; % waktu pengiriman dalam detik
    Throughput2 = paket_diterima_2 ./ max(waktu_pengiriman_2, 1);
    
    % Menyimpan hasil perhitungan delay dan throughput
    delay1(t_idx) = Delay1;
    throughput1(t_idx) = mean(Throughput1); % Menggunakan mean untuk mendapatkan nilai rata-rata jika ada beberapa elemen
    
    delay2(t_idx) = Delay2;
    throughput2(t_idx) = mean(Throughput2); % Menggunakan mean untuk mendapatkan nilai rata-rata jika ada beberapa elemen

    % Plot delay
    figure(3);
    plot(1:t_idx, delay1(1:t_idx), 'g.-'); % Plot delay dari figure 1
    hold on;
    plot(1:t_idx, delay2(1:t_idx), 'r.-');
    h_delay = legend('Normal', 'Under Attack', 'Location', 'northeast');
    set(h_delay, 'Box', 'on');  % Menghilangkan kotak di sekitar legenda
    hold off;

    % Plot throughput
    figure(4);
    plot(1:t_idx, throughput1(1:t_idx), 'g.-'); % Plot throughput dari figure 1
    hold on;
    plot(1:t_idx, throughput2(1:t_idx), 'r.-');
    h_throughput = legend('Normal', 'Under Attack', 'Location', 'northeast');
    set(h_throughput, 'Box', 'on');  % Menghilangkan kotak di sekitar legenda
    hold off;

    % Menunggu sebelum beralih ke iterasi berikutnya
    pause(4.00);
end

hold off;

% Mengambil jumlah unik dari kolom 'sequence' dalam tabel 'result' untuk mendapatkan jumlah node
numNodes = height(unique(result.sequence));

% Inisialisasi AODV
status = repmat('?', 1, numNodes);
dist = inf(1, numNodes);
next = zeros(1, numNodes);

% Inisialisasi status, dist, dan next
for i = 1:numNodes
    if i == 1
        status(i) = '!';
        dist(i) = 0;
        next(i) = 0;
    else
        status(i) = '?';
        % Gunakan hasil perhitungan jarak dari tabel result
        dist(i) = result.d(i);
        next(i) = 1;
    end
end

% Inisialisasi variabel lainnya
flag = 0;
temp = 0;

% Set goalNode
goalNode = 1; % Sesuaikan dengan node tujuan

% Inisialisasi variabel untuk melacak node yang menginisiasi RREQ dan menerima RREP
initiatedRREQ = false(1, numNodes);
receivedRREP = false(1, numNodes);

% Initialize pingResults cell array to store ping information
% pingResults = {};
% pingResults = cell(numNodes, numNodes);
pingResults = cell(numNodes,numNodes); % Inisialisasi dengan sel kosong sebanyak numNodes*numNodes

% Main loop untuk routing AODV
while flag ~= 1 && temp < numNodes
    temp = temp + 1; % Increment iterasi

    % Pilih node dengan dist terkecil dan status '?'
    [minDist, vert] = min(dist(status == '?'));

    % Perbarui status
    status(vert) = '!';

    % Perbarui dist dan next untuk node tetangga
    for i = 1:numNodes
        if status(i) == '?' && dist(i) > dist(vert) + sqrt((result.x(vert) - result.x(i))^2 + (result.y(vert) - result.y(i))^2)
            dist(i) = dist(vert) + sqrt((result.x(vert) - result.x(i))^2 + (result.y(vert) - result.y(i))^2);
            next(i) = vert;

            % Log RREQ
            disp(['Node ' num2str(vert) ' sends RREQ message to node ' num2str(i)]);

            % Simulasikan penerimaan RREP atau timeout berdasarkan proses aktual
            if receivedRREP(vert) % Jika RREP diterima
                % Simpan hasil timeout
                pingResults{vert, i} = ['Node ' num2str(vert) ' to Node ' num2str(i) ': Ping: timeout']; % Set status timeout
            else
                % Simpan hasil ping
                pingResults{vert, i} = ['Node ' num2str(vert) ' to Node ' num2str(i) ': Ping: 100']; % Set status ping
                % Update variabel untuk melacak node yang menginisiasi RREQ dan menerima RREP
                initiatedRREQ(vert) = true;
            end

            % Log RREP
            disp(['Node ' num2str(i) ' sends RREP message to node ' num2str(vert)]);
            receivedRREP(i) = true;
        end
    end

    % Periksa apakah semua node ditandai sebagai '!'
    if all(status == '!')
        flag = 1;
        break;
    end
end

disp('Ping Results:');
for i = 1:numNodes
    for j = 1:numNodes
        if ~isempty(pingResults{i, j})
            disp(pingResults{i, j});
        end
    end
end

% Inisialisasi variabel untuk menyimpan rute
i = goalNode; % Ganti dengan goalNode
count = 1;
route(count) = goalNode;

% Bangun rute dari node terakhir ke node pertama
while next(i) ~= 0 % Ganti dengan node awal
    count = count + 1;
    route(count) = next(i);
    i = next(i);
end

% Tampilkan hasil rute
disp('AODV Route:');
disp(route);

% Inisialisasi daftar sensor berbahaya
M = {};

% Iterasi untuk setiap time step 
for t = 1:99
    % Ambil tabel hasil untuk time step saat ini dan berikutnya dari dalam cell array
    resultTableTimeCurrent = group.ResultTime{t};
    resultTableTimeNext = group.ResultTime{t + 1};
    
    % Ambil nilai unik dari kolom 'id' pada time step saat ini dan berikutnya
    uniqueIdsNAk = unique(resultTableTimeCurrent.sequence);
    uniqueIdsNBk = unique(resultTableTimeNext.sequence);
    NAk = cellstr(uniqueIdsNAk);
    NBk = cellstr(uniqueIdsNBk);
    
    % Inisialisasi tabel lingkungan tetangga hop pertama untuk setiap node A pada waktu t
    neighborListNAk = containers.Map('KeyType', 'char', 'ValueType', 'any');
    % Inisialisasi tabel lingkungan hop pertama untuk setiap node B pada waktu t+1
    neighborListNBk = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    % Bangun tabel lingkungan tetangga hop pertama untuk setiap node A pada waktu t
    for i = 1:numel(NAk)
        A = NAk{i};
        % Cari tetangga untuk node A pada waktu t
        neighborsA = findNeighbor(A, resultTableTimeCurrent);
        neighborListNAk(A) = neighborsA;
    end
    
    % Bangun tabel lingkungan hop pertama untuk setiap node B pada waktu t+1
    for i = 1:numel(NBk)
        B = NBk{i};
        % Cari tetangga untuk node B pada waktu t+1
        neighborsB = findNeighbor(B, resultTableTimeNext);
        neighborListNBk(B) = neighborsB;
    end

    % Iterasi untuk setiap node A dan node B yang berdekatan
    for i = 1:numel(NAk)
        A = NAk{i};
        for j = 1:numel(NBk)
            B = NBk{j};
    
            % Memeriksa interseksi antara N(A)1 dan N(B)1
            if any(ismember(neighborListNAk(A), NBk{j})) || any(ismember(neighborListNBk(B), NBk{j}))
                % Jika N(A)1 ∩ N(B)1 maka anggap sebagai sah
                disp('Sah');
            elseif any(ismember(neighborListNAk(A), NBk{j})) || any(ismember(neighborListNBk(B), union(NAk{i}, NBk{j})))
                % Jika N(A)1 ∩ N(B)2 maka anggap sebagai sah
                disp('Sah');
            else
                % Periksa apakah ada node berwarna merah di waktu sekarang atau berikutnya
                if (any(strcmp(resultTableTimeCurrent.color(strcmp(resultTableTimeCurrent.sequence, A)), 'red')) || ...
                    any(strcmp(resultTableTimeNext.color(strcmp(resultTableTimeNext.sequence, A)), 'red'))) && ...
                   (any(strcmp(resultTableTimeCurrent.color(strcmp(resultTableTimeCurrent.sequence, B)), 'red')) || ...
                    any(strcmp(resultTableTimeNext.color(strcmp(resultTableTimeNext.sequence, B)), 'red')))
                    % Jika ya, tambahkan A dan B ke dalam M
                    M = [M, A, B];
                end
            end
        end
    end
end

% Tampilkan hasil
disp('Daftar sensor berbahaya:');
disp(M);

% Fungsi untuk mencari tetangga suatu node pada suatu waktu
function neighbors = findNeighbor(nodeId, resultTable)
    % Filter hasil untuk node yang sesuai
    nodeResult = resultTable(resultTable.sequence == nodeId, :);
    % Ambil tetangga dari hasil
    if ~isempty(nodeResult) && ismember('neighbor', resultTable.Properties.VariableNames)
        neighbors = unique(nodeResult.neighbor);
    else
        neighbors = [];
    end
end