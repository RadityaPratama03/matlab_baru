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

% Sistem 5G Nilai kisaran
A5 = 498; % Satuan Kbps
B5 = 30;

% Sistem 6G Nilai kisaran
A6 = 500; % Satuan Kbps 
B6 = 30;

% % Sistem Delay
% C = 5;
% % D = 4;
% D = 2;

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

% while t <= 80 
% while t + 1 <= maxIterations && t <= 80
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

%     % Inisialisasi matriks koneksi
%     resultTableTime.koneksi = zeros(size(resultTableTime, 1), size(resultTableTime, 1));
%
%     % Menghitung jumlah koneksi setiap node
%     numConnections = sum(resultTableTime.koneksi, 2);
% 
%     % Membuat koneksi berdasarkan node yang belum mencapai batas
%     for i = 1:size(resultTableTime.koneksi, 1)
%         % Jika node belum memiliki dua koneksi
%         if numConnections(i) < 2
%             % Koneksi dengan node sebelumnya
%             if i > 1
%                 resultTableTime.koneksi(i, i-1) = 1;
%                 resultTableTime.koneksi(i-1, i) = 1;
%                 numConnections(i) = numConnections(i) + 1;
%                 numConnections(i-1) = numConnections(i-1) + 1;
%             end
%             % Koneksi dengan node sesudahnya
%             if i < size(resultTableTime.koneksi, 1)
%                 resultTableTime.koneksi(i, i+1) = 1;
%                 resultTableTime.koneksi(i+1, i) = 1;
%                 numConnections(i) = numConnections(i) + 1;
%                 numConnections(i+1) = numConnections(i+1) + 1;
%             end
%         end
%     end
  
%     % Membuat koneksi berdasarkan node yang belum mencapai batas
%     for i = 1:size(resultTableTime.koneksi, 1)
%         % Jika node belum memiliki dua koneksi
%         if numConnections(i) < 2
%             % Temukan node lain yang belum mencapai batas dan bisa dikoneksikan
%             for j = 1:size(resultTableTime.koneksi, 2)
%                 if i ~= j && numConnections(j) < 2 && resultTableTime.d(i) < 300 && resultTableTime.d(j) < 300
%                     resultTableTime.koneksi(i, j) = 1;
%                     resultTableTime.koneksi(j, i) = 1;
%                     numConnections(i) = numConnections(i) + 1;
%                     numConnections(j) = numConnections(j) + 1;
%                     break; % Hanya satu koneksi yang perlu ditambahkan
%                 end
%             end
%         end
%     end

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


%     % Inisialisasi matriks koneksi
%     resulttime.koneksi = zeros(size(resulttime, 1), size(resulttime, 1));
% 
%     % Nonaktifkan koneksi ke node-node merah
%     redNodesIdx = find(strcmp(resulttime.color, 'red'));
%     if ~isempty(redNodesIdx)
%         for i = 1:length(redNodesIdx)
%             redNode = redNodesIdx(i);
%             resulttime.koneksi(redNode, :) = 0; % Nonaktifkan koneksi ke node lain
%             resulttime.koneksi(:, redNode) = 0; % Nonaktifkan koneksi dari node lain
%         end
%     end
% 
%     % Membuat koneksi ulang berdasarkan node yang tidak terkoneksi
%     for i = 1:size(resulttime.koneksi, 1)
%         if sum(resulttime.koneksi(i, :)) == 0 % Jika node belum terkoneksi dengan siapa pun
%             for j = 1:size(resulttime.koneksi, 2)
%                 if i ~= j && sum(resulttime.koneksi(j, :)) < 2 && resulttime.d(i) < 300 && resulttime.d(j) < 300
%                     resulttime.koneksi(i, j) = 1;
%                     resulttime.koneksi(j, i) = 1;
%                     break; % Hanya satu koneksi yang perlu ditambahkan
%                 end
%             end
%         end
%     end
%=====================================================================
%     % Membuat ulang koneksi berdasarkan nilai d terkecil
%     [~, sortedIdx] = sort(resulttime.d); % Mengurutkan indeks berdasarkan nilai d
%     for i = 1:size(resulttime.koneksi, 1)
%         if sum(resulttime.koneksi(i, :)) == 0 % Jika node belum terkoneksi dengan siapa pun
%             for j = 1:size(resulttime.koneksi, 2)
%                 node = sortedIdx(j);
%                 if i ~= node && min(resulttime.koneksi(node, :)) < 2 && resulttime.d(i) < 300 && resulttime.d(node) < 300
%                     resulttime.koneksi(i, node) = 1;
%                     resulttime.koneksi(node, i) = 1;
%                     break; % Hanya satu koneksi yang perlu ditambahkan
%                 end
%             end
%         end
%     end

    % Menyimpan tabel yang telah dimodifikasi ke dalam cell array
    group.ResultTime{t} = resulttime;

    % Hapus variabel yang tidak ingin ditampilkan di workspace
    clear nonZeroDIdx zeroDIdx;
    clear headClusterIdx maxD minD;
%     clear randomNode redNodesIdx;
end

% % Mengambil jumlah unik dari kolom 'sequence' dalam tabel 'result' untuk mendapatkan jumlah node
% numNodes = height(unique(result.sequence));
% 
% % Inisialisasi AODV
% status = repmat('?', 1, numNodes);
% dist = inf(1, numNodes);
% next = zeros(1, numNodes);
% 
% % Inisialisasi status, dist, dan next
% for i = 1:numNodes
%     if i == 1
%         status(i) = '!';
%         dist(i) = 0;
%         next(i) = 0;
%     else
%         status(i) = '?';
%         % Gunakan hasil perhitungan jarak dari tabel result
%         dist(i) = result.d(i);
%         next(i) = 1;
%     end
% end
% 
% % Inisialisasi variabel lainnya
% flag = 0;
% temp = 0;
% 
% % Set goalNode
% goalNode = 1; % Sesuaikan dengan node tujuan
% 
% % Inisialisasi variabel untuk melacak node yang menginisiasi RREQ dan menerima RREP
% initiatedRREQ = false(1, numNodes);
% receivedRREP = false(1, numNodes);
% 
% % Initialize pingResults cell array to store ping information
% % pingResults = {};
% % pingResults = cell(numNodes, numNodes);
% pingResults = cell(numNodes,numNodes); % Inisialisasi dengan sel kosong sebanyak numNodes*numNodes
% 
% % Main loop untuk routing AODV
% while flag ~= 1 && temp < numNodes
%     temp = temp + 1; % Increment iterasi
% 
%     % Pilih node dengan dist terkecil dan status '?'
%     [minDist, vert] = min(dist(status == '?'));
% 
%     % Perbarui status
%     status(vert) = '!';
% 
%     % Perbarui dist dan next untuk node tetangga
%     for i = 1:numNodes
%         if status(i) == '?' && dist(i) > dist(vert) + sqrt((result.x(vert) - result.x(i))^2 + (result.y(vert) - result.y(i))^2)
%             dist(i) = dist(vert) + sqrt((result.x(vert) - result.x(i))^2 + (result.y(vert) - result.y(i))^2);
%             next(i) = vert;
% 
%             % Log RREQ
%             disp(['Node ' num2str(vert) ' sends RREQ message to node ' num2str(i)]);
% 
%             % Simulasikan penerimaan RREP atau timeout berdasarkan proses aktual
%             if receivedRREP(vert) % Jika RREP diterima
%                 % Simpan hasil timeout
%                 pingResults{vert, i} = ['Node ' num2str(vert) ' to Node ' num2str(i) ': Ping: timeout']; % Set status timeout
% %                 pingResults{end+1} = ['Node ' num2str(vert) ' to Node ' num2str(i) ': Timeout']; % Set status timeout
%             else
%                 % Simpan hasil ping
%                 pingResults{vert, i} = ['Node ' num2str(vert) ' to Node ' num2str(i) ': Ping: 100']; % Set status ping
% %                 pingResults{end+1} = ['Node ' num2str(vert) ' to Node ' num2str(i) ': Ping: 100']; % Set status ping
%                 % Update variabel untuk melacak node yang menginisiasi RREQ dan menerima RREP
%                 initiatedRREQ(vert) = true;
%             end
% 
%             % Log RREP
%             disp(['Node ' num2str(i) ' sends RREP message to node ' num2str(vert)]);
%             receivedRREP(i) = true;
%         end
%     end
% 
%     % Periksa apakah semua node ditandai sebagai '!'
%     if all(status == '!')
%         flag = 1;
%         break;
%     end
% end
% 
% disp('Ping Results:');
% for i = 1:numNodes
%     for j = 1:numNodes
%         if ~isempty(pingResults{i, j})
%             disp(pingResults{i, j});
%         end
%     end
% end
% 
% % % Tampilkan hasil ping
% % disp('Ping Results:');
% % for i = 1:numel(pingResults)
% %     disp(pingResults{i});
% % end
% 
% % % Check for nodes that did not initiate RREQ or did not receive RREP (Timeout)
% % disp('Timeout Results:');
% % for i = 1:numNodes
% %     % Hanya tampilkan node yang tidak menginisiasi RREQ atau tidak menerima RREP
% %     if ~initiatedRREQ(i) || ~receivedRREP(i)
% %         % Simpan hasil timeout
% %         pingResults{vert, i} = ['Node ' num2str(vert) ' to Node ' num2str(i) ': Ping: timeout']; % Set status timeout
% % %         pingResults{end+1} = ['Node ' num2str(i) ' Ping : Timeout'];
% %         disp(['Node ' num2str(vert) ' to Node ' num2str(i) ': Ping: timeout']);
% %     end
% % end
% 
% % Inisialisasi variabel untuk menyimpan rute
% i = goalNode; % Ganti dengan goalNode
% count = 1;
% route(count) = goalNode;
% 
% % Bangun rute dari node terakhir ke node pertama
% while next(i) ~= 0 % Ganti dengan node awal
%     count = count + 1;
%     route(count) = next(i);
%     i = next(i);
% end
% 
% % Tampilkan hasil rute
% disp('AODV Route:');
% disp(route);
% 
% % Inisialisasi daftar sensor berbahaya
% M = {};
% 
% % Iterasi untuk setiap time step 
% for t = 1:99
%     % Ambil tabel hasil untuk time step saat ini dan berikutnya dari dalam cell array
%     resultTableTimeCurrent = group.ResultTime{t};
%     resultTableTimeNext = group.ResultTime{t + 1};
%     
%     % Ambil nilai unik dari kolom 'id' pada time step saat ini dan berikutnya
%     uniqueIdsNAk = unique(resultTableTimeCurrent.sequence);
%     uniqueIdsNBk = unique(resultTableTimeNext.sequence);
%     NAk = cellstr(uniqueIdsNAk);
%     NBk = cellstr(uniqueIdsNBk);
%     
%     % Inisialisasi tabel lingkungan tetangga hop pertama untuk setiap node A pada waktu t
%     neighborListNAk = containers.Map('KeyType', 'char', 'ValueType', 'any');
%     % Inisialisasi tabel lingkungan hop pertama untuk setiap node B pada waktu t+1
%     neighborListNBk = containers.Map('KeyType', 'char', 'ValueType', 'any');
%     
%     % Bangun tabel lingkungan tetangga hop pertama untuk setiap node A pada waktu t
%     for i = 1:numel(NAk)
%         A = NAk{i};
%         % Cari tetangga untuk node A pada waktu t
%         neighborsA = findNeighbor(A, resultTableTimeCurrent);
%         neighborListNAk(A) = neighborsA;
%     end
%     
%     % Bangun tabel lingkungan hop pertama untuk setiap node B pada waktu t+1
%     for i = 1:numel(NBk)
%         B = NBk{i};
%         % Cari tetangga untuk node B pada waktu t+1
%         neighborsB = findNeighbor(B, resultTableTimeNext);
%         neighborListNBk(B) = neighborsB;
%     end
% 
%     % Iterasi untuk setiap node A dan node B yang berdekatan
%     for i = 1:numel(NAk)
%         A = NAk{i};
%         for j = 1:numel(NBk)
%             B = NBk{j};
%     
%             % Memeriksa interseksi antara N(A)1 dan N(B)1
%             if any(ismember(neighborListNAk(A), NBk{j})) || any(ismember(neighborListNBk(B), NBk{j}))
%                 % Jika N(A)1 ∩ N(B)1 maka anggap sebagai sah
%                 disp('Sah');
%             elseif any(ismember(neighborListNAk(A), NBk{j})) || any(ismember(neighborListNBk(B), union(NAk{i}, NBk{j})))
%                 % Jika N(A)1 ∩ N(B)2 maka anggap sebagai sah
%                 disp('Sah');
%             else
%                 % Periksa apakah ada node berwarna merah di waktu sekarang atau berikutnya
%                 if (any(strcmp(resultTableTimeCurrent.color(strcmp(resultTableTimeCurrent.sequence, A)), 'red')) || ...
%                     any(strcmp(resultTableTimeNext.color(strcmp(resultTableTimeNext.sequence, A)), 'red'))) && ...
%                    (any(strcmp(resultTableTimeCurrent.color(strcmp(resultTableTimeCurrent.sequence, B)), 'red')) || ...
%                     any(strcmp(resultTableTimeNext.color(strcmp(resultTableTimeNext.sequence, B)), 'red')))
%                     % Jika ya, tambahkan A dan B ke dalam M
%                     M = [M, A, B];
%                 end
%             end
%         end
%     end
% end
% 
% % Tampilkan hasil
% disp('Daftar sensor berbahaya:');
% disp(M);

% Inisialisasi warna untuk plotting
warna = {'blue', 'red', 'green', 'black', 'cyan', 'magenta', 'yellow', 'white'};

% Inisialisasi delay dan throughput
delay1 = zeros(1, 100);
throughput1 = zeros(1, 100);

% Inisialisasi delay dan throughput
delay2 = zeros(1, 100);
throughput2 = zeros(1, 100);

% Membuat plot untuk setiap nilai t dari 1 hingga 40
for t_idx = 1:3
    % Membersihkan figur pertama sebelum memplot iterasi berikutnya
    figure(1);
    clf;
    cla;
    axis([-50 350 -40 120]);
%     title('Jalur PKU - Node Kendaraan & Head Cluster');
    title(['Jalur PKU - Node Kendaraan & Head Cluster - Iterasi ', num2str(t_idx)]);
    xlabel('Data x');
    ylabel('Data y');
    grid on;
    hold on;

    % Membersihkan figur kedua sebelum memplot iterasi berikutnya
    figure(2);
    clf;
    cla;
    axis([-50 350 -40 120]);
%     title('Jalur PKU - Node Kendaraan & Malicious');
    title(['Jalur PKU - Node Kendaraan & Malicious - Iterasi ', num2str(t_idx)]);
    xlabel('Data x');
    ylabel('Data y');
    grid on;
    hold on;

    % Membersihkan figur delay sebelum memplot iterasi berikutnya
    figure(3);
%     axis([10 inf 155 283]);
%     axis([10 inf 0 200]);
    axis('auto');
    title('Delay');
    xlabel('Jumlah Kendaraan (s)');
    ylabel('Delay (ms)');
    grid on;
    hold on;

    % Membersihkan figur throughput sebelum memplot iterasi berikutnya
    figure(4);
    axis('auto');
    title('Throughput');
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
        
%         % Menggambar koneksi antar node
%         connectedNodes = find(resultTableTime.koneksi(i, :) == 1);
%         for j = 1:length(connectedNodes)
%             node = connectedNodes(j);
%             if i < node
%                 figure(1);
%                 plot([resultTableTime.x(i), resultTableTime.x(node)], [resultTableTime.y(i), resultTableTime.y(node)], 'b--', 'LineWidth', 1);
%             end
%         end
    end


%     for i = 1:size(resultTableTime, 1)        
%         if strcmp(resultTableTime.color{i}, 'Head Cluster')
%             figure(1);
%             scatter(resultTableTime.x(i), resultTableTime.y(i), 100, 'green', 'X', 'LineWidth', 1.5); % Simbol X untuk Head Cluster
%         elseif strcmp(resultTableTime.color{i}, 'blue')
%             figure(1);
%             scatter(resultTableTime.x(i), resultTableTime.y(i), 64, 'blue', 'o', 'filled'); % Titik-titik biru
%         end
%         
%         % Plot garis antar node berdasarkan nilai d pada t saat ini
%         if i < size(resultTableTime, 1)
%             d = resultTableTime.d(i);
%             if d <= 300
%                 figure(1);
%                 plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
%             end
%         end
%         
%         % Menggambar koneksi antar node
%         connectedNodes = find(resultTableTime.koneksi(i, :) == 1);
%         for j = 1:length(connectedNodes)
%             node = connectedNodes(j);
%             if i < node && resultTableTime.d(i) <= 300 && resultTableTime.d(node) <= 300
%                 figure(1);
%                 plot([resultTableTime.x(i), resultTableTime.x(node)], [resultTableTime.y(i), resultTableTime.y(node)], 'b--', 'LineWidth', 1);
%             end
%         end
%     end

    % Menambahkan legenda untuk figure pertama
    figure(1);
    hold on; 
    h1 = scatter(NaN, NaN, 100, 'green', 'X', 'LineWidth', 1.5); 
    h2 = scatter(NaN, NaN, 64, 'blue', 'o', 'filled'); 
    leg1 = legend([h1, h2], 'Head Cluster', 'Node Kendaraan', 'Location', 'northeast');
    set(leg1, 'Box', 'off');
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
            scatter(resulttime.x(i), resulttime.y(i), 64, 'r', 'filled');  % Mengganti warna node merah
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
    set(leg2, 'Box', 'off');
    hold off; 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Inisialisasi matriks untuk menyimpan data delay dan throughput
    Delay_avg1 = zeros(size(resultTableTime, 1), 1);
    Throughput_avg1 = zeros(size(resultTableTime, 1), 1);

    % Inisialisasi matriks untuk menyimpan data delay dan throughput dari figure 2
    Delay_avg2 = zeros(size(resulttime, 1), 1);
    Throughput_avg2 = zeros(size(resulttime, 1), 1);
    
    % Variabel untuk delay dan throughput
    factor_delay = 3;
    factor_throughput = 2;

    % Iterasi untuk setiap titik data dalam resultTableTime
    for i = 2:size(resultTableTime, 1)
        % Menghitung delay dan throughput untuk figure 1
        Delay1 = 2 + 10 * factor_delay;
        Throughput1 = A6 - B6 * factor_throughput;
        
        % Menyimpan nilai delay dan throughput untuk titik data ke-i dari figure 1
        Delay_avg1(i) = Delay1;
        Throughput_avg1(i) = Throughput1;
        
        % Update faktor untuk iterasi berikutnya
        factor_delay = factor_delay + 1;
        factor_throughput = factor_throughput + 1;
    end
    
    % Iterasi untuk setiap titik data dalam resulttime
    for i = 2:size(resulttime, 1)
        % Menghitung delay dan throughput untuk figure 2
        Delay2 = 2 + 10 * factor_delay;
        Throughput2 = A6 - B6 * factor_throughput;
        
        % Menyimpan nilai delay dan throughput untuk titik data ke-i dari figure 2
        Delay_avg2(i) = Delay2;
        Throughput_avg2(i) = Throughput2;
        
        % Update faktor untuk iterasi berikutnya
        factor_delay = factor_delay + 1;
        factor_throughput = factor_throughput + 1;
    end
    
    % Menyimpan hasil perhitungan delay dan throughput
    delay1(t_idx) = Delay1;
    throughput1(t_idx) = Throughput1;
    
    % Menambahkan hasil perhitungan delay dan throughput ke delay dan throughput total
    delay1(t_idx) = Delay_avg1(end); % Mengambil delay untuk data terakhir dari resultTableTime
    throughput1(t_idx) = Throughput_avg1(end); % Mengambil throughput untuk data terakhir dari resultTableTime

    % Menyimpan hasil perhitungan delay dan throughput
    delay2(t_idx) = Delay2;
    throughput2(t_idx) = Throughput2;

    % Menambahkan hasil perhitungan delay dan throughput ke delay dan throughput total
    delay2(t_idx) = Delay_avg2(end); % Mengambil delay untuk data terakhir dari resulttime
    throughput2(t_idx) = Throughput_avg2(end); % Mengambil throughput untuk data terakhir dari resulttime

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Plotting delay
    figure(3);
    plot(1:t_idx, delay1(1:t_idx), 'g.-'); % Plot delay dari figure 1
    hold on;
    plot(1:t_idx, delay2(1:t_idx), 'r.-');
    h_delay = legend('Normal', 'Under Attack', 'Location', 'northeast');
    set(h_delay, 'Box', 'off');  % Menghilangkan kotak di sekitar legenda
    hold off;
    
    % Plotting throughput
    figure(4);
    plot(1:t_idx, throughput1(1:t_idx), 'g.-'); % Plot throughput dari figure 1
    hold on;
    plot(1:t_idx, throughput2(1:t_idx), 'r.-');
    h_throughput = legend('Normal', 'Under Attack', 'Location', 'northeast');
    set(h_throughput, 'Box', 'off');  % Menghilangkan kotak di sekitar legenda
    hold off;

    % Menunggu sebelum beralih ke iterasi berikutnya
    pause(1.00);
end

hold off;

% % Fungsi untuk mencari tetangga suatu node pada suatu waktu
% function neighbors = findNeighbor(nodeId, resultTable)
%     % Filter hasil untuk node yang sesuai
%     nodeResult = resultTable(resultTable.sequence == nodeId, :);
%     % Ambil tetangga dari hasil
%     if ~isempty(nodeResult) && ismember('neighbor', resultTable.Properties.VariableNames)
%         neighbors = unique(nodeResult.neighbor);
%     else
%         neighbors = [];
%     end
% end