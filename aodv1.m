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

start1 = 1;

figure; % Membuat figure baru

% subplot(2, 1, 1);
% axis([-50 350 -40 120]);
% title('Jalur PKU');
% xlabel('Data x');
% ylabel('Data y');
% grid on;
% hold on;
% 
% subplot(2, 1, 2);
% axis([-50 350 -40 120]);
% title('Jalur PKU');
% xlabel('Data x');
% ylabel('Data y');
% grid on;
% hold on;

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

% % Inisialisasi tabel untuk menyimpan hasil
% result = table('Size', [80, 5], ...
%     'VariableTypes', {'double', 'double', 'string', 'double', 'double'}, ...
%     'VariableNames', {'t', 'd', 'id', 'x', 'y'});

% Initialize the 'result' table with necessary variables
result = table('Size', [80, 7], ...
    'VariableTypes', {'double', 'double', 'string', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'t', 'd', 'id', 'x', 'y', 'RREPSN', 'SSN'});

% while t <= 80 
% while t + 1 <= maxIterations && t <= 80
while t + 1 <= maxIterations 
    % Increment t
    t = t + 1;

    % Kalkulasi nilai d hanya untuk titik tertentu
    d = sqrt((data.x(t) - data.x(t- 1)).^2 + (data.y(t) - data.y(t- 1)).^2);

    % Menyimpan nilai t, d, id, x, dan y ke dalam result
    result.t(t) = data.time(t);
    result.d(t) = d;
    result.id{t} = data.id{t};
    result.x(t) = data.x(t);
    result.y(t) = data.y(t);
end

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
    for idx = 1:numel(ids_current)
        id = ids_current{idx};
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

% Menggabungkan data t dan id menjadi data baru 'sequence' di tabel result
result.SSN = zeros(size(result.id));

% Inisialisasi struktur untuk menyimpan jumlah kemunculan setiap ID pada setiap iterasi
id_count = containers.Map('KeyType', 'char', 'ValueType', 'double');

for t = 1:max(result.t)
    % Mendapatkan ID yang muncul pada iterasi saat ini
    ids_current = unique(result.id(result.t == t));
    
    % Loop melalui setiap ID yang muncul pada iterasi saat ini
    for id_idx = 1:numel(ids_current)
        id = ids_current{id_idx};
        % Jika ID tidak ada dalam struktur id_count, tambahkan dan atur nilai awalnya menjadi 0
        if ~isKey(id_count, id)
            id_count(id) = 0;
        end
        % Mendapatkan jumlah kemunculan ID pada iterasi sebelumnya
        count_prev = id_count(id);
        
        % Mendapatkan indeks ID pada iterasi saat ini
        idx_current = find(strcmp(result.id, id) & result.t == t);
        
        % Memperbarui sequence untuk ID pada iterasi saat ini dengan indeks unik yang tepat
        for i = 1:numel(idx_current)
            % Mengubah tipe data SSN menjadi integer dan memulai pengurutan dari time 1
            result.SSN(idx_current(i)) = count_prev + i;
        end
        
        % Mengupdate jumlah kemunculan ID
        id_count(id) = count_prev + numel(idx_current);
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

    % Temukan indeks baris dengan nilai d terkecil dan terbesar
    minD = find(resultTableTime.d == min(resultTableTime.d(resultTableTime.d > 0)), 1, 'first');
    maxD = find(resultTableTime.d >= 300);

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

    % Menyimpan tabel yang telah dimodifikasi ke dalam cell array
    group.Result{t} = resultTableTime;

    % Hapus variabel yang tidak ingin ditampilkan di workspace
    clear nonZeroDIdx zeroDIdx;
    clear headClusterIdx maxD minD;
    clear A B;
%     clear N_Ak N_Bk;
end

% % Inisialisasi warna untuk plotting
% warna = {'blue', 'red', 'green', 'black', 'cyan', 'magenta', 'yellow', 'white'};
% 
% % Membuat plot untuk setiap nilai t dari 1 hingga 20
% for t_idx = 1:20
%     % Mengambil tabel dari dalam cell array
%     resultTableTime = group.Result{t_idx};
% 
%     % Membuat plot (digunakan 'hold on' hanya pada iterasi pertama)
%     if t_idx == 1
%         hold on;
%     else
%         % Membersihkan figur sebelum memplot iterasi berikutnya
%         clf;
%         hold on;
%     end
% 
%     % Plot data pada subplot pertama
%     subplot(2, 1, 1);
%     hold on;
% 
%     for i = 1:size(resultTableTime, 1)
%         if strcmp(resultTableTime.color{i}, 'Head Cluster')
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'X', 'Color', 'green', 'MarkerSize', 15, 'MarkerFaceColor', 'green', 'LineWidth', 1.5);
%         elseif strcmp(resultTableTime.color{i}, 'blue')
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'blue', 'MarkerSize', 8, 'MarkerFaceColor', 'blue', 'LineWidth', 1);
%         else
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', warna{mod(i, length(warna)) + 1}, 'MarkerSize', 8, 'MarkerFaceColor', warna{mod(i, length(warna)) + 1}, 'LineWidth', 1);
%         end
%     end  
% 
%     title(['Plot 1 Data untuk t = ' num2str(t_idx)]);
%     
% %     % Plot garis antar node berdasarkan nilai d pada t saat ini
% %     for i = 1:size(resultTableTime, 1)-1
% %         d = resultTableTime.d(i);
% %         if d <= 300 
% %             plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
% %         else
% %             plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'r--', 'LineWidth', 1);
% %         end
% %     end
% 
%     % Plot garis antar node berdasarkan nilai d pada t saat ini
%     for i = 1:size(resultTableTime, 1)-1
%         d = resultTableTime.d(i);
%         if d <= 300
%             plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
%         else
%             plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
% %             % Tidak memplot garis jika nilai d > 300 (node terputus)
% %             if i > 1 && resultTableTime.d(i-1) <= 300
% %                 % Jika node sebelumnya terhubung (d <= 300), maka node saat ini yang awalnya terputus bisa terhubung kembali
% %                 plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
% %             end
%         end
%     end
% 
%     % Plot data pada subplot kedua
%     subplot(2, 1, 2);
%     hold on;
% 
%     % Tentukan indeks head cluster di grafik pertama
%     originalHeadClusterIndex = find(strcmp(group.Result{1}.color, 'Head Cluster'));
%     
%     % Tentukan indeks head cluster di grafik kedua
%     newHeadClusterIndex = mod(originalHeadClusterIndex + t_idx - 1, size(resultTableTime, 1)) + 1;
%     
%     % Tentukan node yang ditinggalkan oleh head cluster
%     nodesDitinggalkan = originalHeadClusterIndex(originalHeadClusterIndex ~= newHeadClusterIndex);
% 
%     for i = 1:size(resultTableTime, 1)
%         if i == newHeadClusterIndex
%             % Plot head cluster baru sebagai 'X' hijau
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'X', 'Color', 'green', 'MarkerSize', 15, 'MarkerFaceColor', 'green', 'LineWidth', 1.5);
%         elseif ~any(i == nodesDitinggalkan)
%             % Plot node yang tersisa sebagai 'o' biru
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'blue', 'MarkerSize', 8, 'MarkerFaceColor', 'blue', 'LineWidth', 1);
%         else
%             % Plot semua node lainnya sebagai biru
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'blue', 'MarkerSize', 8, 'MarkerFaceColor', 'blue', 'LineWidth', 1);
%         end
%     end
%     
%     title(['Plot 2 Data untuk t = ' num2str(t_idx)]);
%     
%     % Plot garis antar node berdasarkan nilai d pada t saat ini
%     for i = 1:size(resultTableTime, 1)-1
%         d = resultTableTime.d(i);
%         if d <= 200
%             plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
%         else
%             % Tidak memplot garis jika nilai d > 300 (node terputus)
%             if i > 1 && resultTableTime.d(i-1) 
%                 % Cari node untuk koneksi yang tersisa
%                 nodeUntukKoneksi = setdiff(1:size(resultTableTime, 1), [i, nodesDitinggalkan]);
%                 % Jika ada node yang tersisa untuk koneksi, hubungkan dengan salah satu dari mereka
%                 if ~isempty(nodeUntukKoneksi)
%                     plot([resultTableTime.x(i), resultTableTime.x(nodeUntukKoneksi(1))], [resultTableTime.y(i), resultTableTime.y(nodeUntukKoneksi(1))], 'r--', 'LineWidth', 1);
%                 end
%             end
%         end
%     end
%     
% %     for i = 1:size(resultTableTime, 1)
% %         if i == newHeadClusterIndex
% %             % Plot head cluster baru sebagai 'X' hijau
% %             plot(resultTableTime.x(i), resultTableTime.y(i), 'X', 'Color', 'green', 'MarkerSize', 15, 'MarkerFaceColor', 'green', 'LineWidth', 1.5);
% %         elseif i == nodesDitinggalkan
% %             % Node yang ditinggalkan oleh head cluster menjadi biru
% %             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'blue', 'MarkerSize', 8, 'MarkerFaceColor', 'blue', 'LineWidth', 1);
% %         else
% %             % Plot semua node lainnya sebagai biru
% %             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'blue', 'MarkerSize', 8, 'MarkerFaceColor', 'blue', 'LineWidth', 1);
% %         end
% %     end
% % 
% %     title(['Plot 2 Data untuk t = ' num2str(t_idx)]);
% %     
% %     % Plot garis antar node berdasarkan nilai d pada t saat ini
% %     for i = 1:size(resultTableTime, 1)-1
% %         d = resultTableTime.d(i);
% %         if d <= 300 
% %             plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
% %         else
% %             plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'r--', 'LineWidth', 1);
% %         end
% %     end
% % 
% %     % Plot garis antar node berdasarkan nilai d pada t saat ini
% %     for i = 1:size(resultTableTime, 1)-1
% %         d = resultTableTime.d(i);
% %         if d <= 150
% %             plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'b--', 'LineWidth', 1);
% %         else
% %             % Tidak memplot garis jika nilai d > 300 (node terputus)
% %             if i > 1 && resultTableTime.d(i-1) <= 150
% %                 % Jika node sebelumnya terhubung (d <= 150), maka node saat ini yang awalnya terputus bisa terhubung kembali dengan node lain
% %                 % Misalnya, terhubung kembali dengan node pertama di dalam tabel hasil (group.Result)
% %                 plot([resultTableTime.x(i), resultTableTime.x(1)], [resultTableTime.y(i), resultTableTime.y(1)], 'b--', 'LineWidth', 1);
% %             end
% %         end
% %     end
%   
%     pause(0.01);
% 
% end
% hold off; 

% Tentukan jumlah baris yang ingin digunakan
jumlah_baris = 39; % misalnya 120 baris

% Ambil sejumlah baris tertentu dari tabel result
data_terbatas = result(1:jumlah_baris, :);

% Mengambil jumlah unik dari kolom 'id' dalam tabel 'data_terbatas' untuk mendapatkan jumlah node
numNodes = numel(unique(data_terbatas.sequence));
% numNodes = height(unique(result.sequence));

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

% RREPSN = zeros(1, numNodes);

% Initialize pingResults cell array to store ping information
pingResults = cell(numNodes, numNodes);

% Initialize sequence number
RREPSN = 1;

% Inisialisasi variabel untuk menyimpan nomor urutan RREP untuk setiap node
RREPSN = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

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
                % Cek apakah node ini sudah memiliki nomor urutan RREP
                if ~isKey(RREPSN, i)
                    % Jika belum, tambahkan nomor urutan RREP untuk node ini
                    RREPSN(i) = RREPSN.Count + 1;
                end
                
                % Simpan hasil ping dengan nomor urutan RREP
                pingResults{vert, i} = ['Node ' num2str(vert) ' to Node ' num2str(i) ' with sequence number ' num2str(RREPSN(i)) ': Ping: 100']; % Set status ping
                % Update variabel untuk melacak node yang menginisiasi RREQ dan menerima RREP
                initiatedRREQ(vert) = true;
            else
                % Simpan hasil timeout
                pingResults{vert, i} = ['Node ' num2str(vert) ' to Node ' num2str(i) ' with sequence number ' num2str(RREPSN(i)) ': Ping: timeout']; % Set status timeout
            end

            % Log RREP
            disp(['Node ' num2str(i) ' sends RREP message to node ' num2str(vert) ' with sequence number ' num2str(RREPSN(i))]);
            receivedRREP(i) = true;
        end
    end

    % Periksa apakah semua node ditandai sebagai '!'
    if all(status == '!')
        flag = 1;
        break;
    end
end

% Output pingResults
disp('Ping Results:');
for i = 1:numNodes
    for j = 1:numNodes
        if ~isempty(pingResults{i, j})
            disp(pingResults{i, j});
        end
    end
end

% Output RREPSN
disp('RREPSN:');
keys = RREPSN.keys;
while keys.hasNext
    key = keys.next;
    disp(['Node ' num2str(key) ' : ' num2str(RREPSN(key))]);
end



% % Tampilkan hasil ping
% disp('Ping Results:');
% for i = 1:numel(pingResults)
%     disp(pingResults{i});
% end

% % Check for nodes that did not initiate RREQ or did not receive RREP (Timeout)
% disp('Timeout Results:');
% for i = 1:numNodes
%     % Hanya tampilkan node yang tidak menginisiasi RREQ atau tidak menerima RREP
%     if ~initiatedRREQ(i) || ~receivedRREP(i)
%         % Simpan hasil timeout
%         pingResults{vert, i} = ['Node ' num2str(vert) ' to Node ' num2str(i) ': Ping: timeout']; % Set status timeout
% %         pingResults{end+1} = ['Node ' num2str(i) ' Ping : Timeout'];
%         disp(['Node ' num2str(vert) ' to Node ' num2str(i) ': Ping: timeout']);
%     end
% end

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

% % Inisialisasi daftar sensor berbahaya
% M = {};
% 
% % Iterasi untuk setiap time step kecuali yang terakhir
% for t = 1:99
%     % Ambil tabel hasil untuk time step saat ini dan berikutnya dari dalam cell array
%     resultTableTimeCurrent = group.Result{t};
%     resultTableTimeNext = group.Result{t + 1};
%     
%     % Ambil nilai unik dari kolom 'id' pada time step saat ini dan berikutnya
%     uniqueIdsNAk = unique(resultTableTimeCurrent.id);
%     uniqueIdsNBk = unique(resultTableTimeNext.id);
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
% %                 % Jika tidak, anggap sebagai berbahaya dan tambahkan A dan B ke M
% %                 if ~isempty(M) && ~any(contains(M, A)) && ~any(contains(M, B))
% %                     M = [M, A, B];
% %                 elseif isempty(M)
% %                     M = [M, A, B];
% %                 end
% %                 % Broadcast M
% %                 disp(['Malicious: Node A: ', A, ', Node B: ', B]);
%             end
%         end
%     end
% end
% 
% % Tampilkan hasil
% disp('Daftar sensor berbahaya:');
% disp(M);
% 
% % Fungsi untuk mencari tetangga suatu node pada suatu waktu
% function neighbors = findNeighbor(nodeId, resultTable)
%     % Filter hasil untuk node yang sesuai
%     nodeResult = resultTable(resultTable.id == nodeId, :);
%     % Ambil tetangga dari hasil
%     if ~isempty(nodeResult) && ismember('neighbor', resultTable.Properties.VariableNames)
%         neighbors = unique(nodeResult.neighbor);
%     else
%         neighbors = [];
%     end
% end

%=================================================================================================================================================

% Tentukan jumlah baris yang ingin digunakan
% jumlah_baris = 317; % misalnya 120 baris
% 
% % Ambil sejumlah baris tertentu dari tabel result
% data_terbatas = result(1:jumlah_baris, :);
% 
% % Mengambil jumlah unik dari kolom 'id' dalam tabel 'data_terbatas' untuk mendapatkan jumlah node
% numNodes = numel(unique(data_terbatas.id));
% 
% goalNode = 1; % Atur node tujuan sesuai kebutuhan
% 
% % Temukan indeks node tujuan (goalNode) dalam tabel result
% goalNodeIndex = find(result.id == num2str(goalNode));
% 
% % Inisialisasi status, dist, dan next
% status = repmat('?', 1, numNodes);
% dist = inf(1, numNodes);
% next = zeros(1, numNodes);
% 
% % Inisialisasi status, dist, dan next untuk node tujuan (goalNode)
% status(goalNodeIndex) = '!';
% dist(goalNodeIndex) = 0;
% next(goalNodeIndex) = goalNodeIndex;
% 
% % Inisialisasi variabel lainnya
% flag = 0;
% temp = 0;
% 
% % Initialize variables to store ping information
% pingResults = cell(numNodes, numNodes);
% sentRREQTime = zeros(numNodes, numNodes);
% 
% while flag ~= 1 && temp < numNodes
%     temp = temp + 1; % Tambahkan iterasi
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
%             % Log RREQ dan catat waktu pengiriman
%             disp(['Node ' num2str(vert) ' sends RREQ message to node ' num2str(i)]);
%             sentRREQTime(vert, i) = temp; % Simpan waktu pengiriman
% 
%             % Simulate reply or timeout based on distance
%             if sqrt((result.x(vert) - result.x(i))^2 + (result.y(vert) - result.y(i))^2) < 300
%                 pingResults{vert, i} = 'Ping: 100';
%                 % Catat waktu penerimaan RREP
%                 receivedRREPTime = temp; % Simpan waktu penerimaan
%             else
%                 pingResults{vert, i} = 'Timeout';
%                 % Tambahkan kondisi untuk keluar dari loop jika goalNode tercapai
%                 if i == goalNode
%                     flag = 1;
%                     break;
%                 end
%             end
% 
%             % Log RREP
%             disp(['Node ' num2str(i) ' sends RREP message to node ' num2str(vert)]);
% 
%             % Tambahkan kondisi untuk keluar dari loop jika goalNode tercapai
%             if i == goalNode
%                 flag = 1;
%                 break;
%             end
%         end
%     end
% 
%     if all(status == '!')
%         flag = 1;
%         break;
%     end
% 
%     % pause(2.0);  % Add a pause to slow down the animation
% end
% 
% % Display ping results and sent/received times
% disp('Ping Results:');
% for i = 1:numNodes
%     for j = 1:numNodes
%         if ~isempty(pingResults{i, j})
%             disp(['Node ' num2str(i) ' to Node ' num2str(j) ': ' pingResults{i, j}]);
%             disp(['   Sent RREQ Time: ' num2str(sentRREQTime(i, j))]);
%             if strcmp(pingResults{i, j}, 'Ping: 100')
%                 disp(['   Received RREP Time: ' num2str(receivedRREPTime)]);
%             end
%         end
%     end
% end
% 
% % Check for nodes that did not initiate RREQ or did not receive RREP (Timeout)
% disp('Timeout Results:');
% for i = 1:numNodes
%     initiatedRREQ = find(~cellfun('isempty', pingResults(i, :)));
%     receivedRREP = find(cellfun(@(x) strcmp(x, 'Ping: 100'), pingResults(i, :)));
%     
% %     % Hanya tampilkan node yang tidak menginisiasi RREQ atau tidak menerima RREP
% %     if isempty(initiatedRREQ) || isempty(receivedRREP)
% %         % Ubah hasil ping menjadi 'Timeout' untuk setiap kolom pada baris i
% %         for j = 1:numNodes
% %             pingResults{i, j} = 'Timeout';
% %         end
% %         
% %         % Tampilkan hasil timeout untuk node i
% % %         disp(['Node ' num2str(i) ' Ping : Timeout']);
% %     end
% end
% 
% % Inisialisasi variabel untuk menyimpan rute
% i = goalNodeIndex; % Ganti dengan goalNodeIndex
% count = 1;
% route(count) = goalNode;
% 
% % Bangun rute dari node terakhir ke node pertama
% while next(i) ~= goalNodeIndex % Ganti dengan goalNodeIndex
%     count = count + 1;
%     route(count) = next(i);
%     i = next(i);
% end
% 
% % Tampilkan hasil rute
% disp('AODV Route:');
% disp(route);


% % Inisialisasi daftar sensor berbahaya
% M = {};
% 
% % Iterasi untuk setiap time step kecuali yang terakhir
% for t = 1:99
%     % Ambil tabel hasil untuk time step saat ini dan berikutnya dari dalam cell array
%     resultTableTimeCurrent = group.Result{t};
%     resultTableTimeNext = group.Result{t + 1};
%     
%     % Ambil nilai unik dari kolom 'id' pada time step saat ini dan berikutnya
%     uniqueIdsNAk = unique(resultTableTimeCurrent.id);
%     uniqueIdsNBk = unique(resultTableTimeNext.id);
%     NAk = cellstr(uniqueIdsNAk);
%     NBk = cellstr(uniqueIdsNBk);
%     
%     % Inisialisasi neighbor list untuk setiap node A pada waktu t
%     neighborListNAk = containers.Map('KeyType', 'char', 'ValueType', 'any');
%     % Inisialisasi neighbor list untuk setiap node B pada waktu t+1
%     neighborListNBk = containers.Map('KeyType', 'char', 'ValueType', 'any');
%     
%     % Iterasi untuk setiap node A pada waktu t
%     for i = 1:numel(NAk)
%         A = NAk{i};
%         % Cari tetangga untuk node A pada waktu t
%         neighborA = findNeighbor(A, resultTableTimeCurrent);
%         neighborListNAk(A) = neighborA;
%     end
%     
%     % Iterasi untuk setiap node B pada waktu t+1
%     for i = 1:numel(NBk)
%         B = NBk{i};
%         % Cari tetangga untuk node B pada waktu t+1
%         neighborB = findNeighbor(B, resultTableTimeNext);
%         neighborListNBk(B) = neighborB;
%     end
%     
%     % Iterasi untuk setiap node A dan node B yang berdekatan
%     for i = 1:numel(NAk)
%         A = NAk{i};
%         for j = 1:numel(NBk)
%             B = NBk{j};
% 
%             % Memeriksa interseksi antara N(A)1 dan N(B)1
%             if strcmp(A, NAk{1}) && strcmp(B, NBk{1})
%                 % Jika N(A)1 ∩ N(B)1 maka anggap sebagai sah
%                 disp('Legitimate');
%             elseif strcmp(A, NAk{1}) && strcmp(B, NBk{2})
%                 % Jika N(A)1 ∩ N(B)2 maka anggap sebagai sah
%                 disp('Legitimate');
%             else
% %                 % Jika tidak, anggap sebagai berbahaya dan tambahkan A dan B ke M
% %                 if ~isempty(M) && ~any(contains(M, A)) && ~any(contains(M, B))
% %                     M = [M, A, B];
% %                 elseif isempty(M)
% %                     M = [M, A, B];
% %                 end
% %                 % Broadcast M
% %                 disp(['Node A: ', A, ' Node B: ', B, ' Broadcast M: ', strjoin(M, ', ')]);
%             end
%         end
%     end
%     
%     % Lakukan analisis dan pengecekan di sini...
%     
%     % Contoh: Tampilkan neighbor list untuk waktu t
%     disp(['Neighbor List pada waktu ', num2str(t)]);
%     disp('NAk:');
%     disp(neighborListNAk);
%     disp('NBk:');
%     disp(neighborListNBk);
% end
% 
% % Fungsi untuk mencari tetangga suatu node pada suatu waktu
% function neighbors = findNeighbor(nodeId, resultTable)
%     % Filter hasil untuk node yang sesuai
%     nodeResult = resultTable(resultTable.id == nodeId, :);
%     % Ambil tetangga dari hasil
%     if ~isempty(nodeResult) && ismember('neighbor', resultTable.Properties.VariableNames)
%         neighbors = unique(nodeResult.neighbor);
%     else
%         neighbors = [];
%     end
% end


% % Inisialisasi daftar sensor berbahaya
% M = {};
% 
% % Iterasi untuk setiap time step kecuali yang terakhir
% for t = 1:99
%     % Ambil tabel hasil untuk time step saat ini dan berikutnya dari dalam cell array
%     resultTableTimeCurrent = group.Result{t};
%     resultTableTimeNext = group.Result{t + 1};
%     
%     % Ambil nilai unik dari kolom 'id' pada time step saat ini dan berikutnya
%     uniqueIdsNAk = unique(resultTableTimeCurrent.id);
%     uniqueIdsNBk = unique(resultTableTimeNext.id);
%     NAk = cellstr(uniqueIdsNAk);
%     NBk = cellstr(uniqueIdsNBk);
% 
%     % Iterasi untuk setiap node A dan node B yang berdekatan
%     for i = 1:numel(NAk)
%         A = NAk{i};
%         for j = 1:numel(NBk)
%             B = NBk{j};
% 
%             % Memeriksa interseksi antara N(A)1 dan N(B)1
%             if strcmp(A, NAk{1}) && strcmp(B, NBk{1})
%                 % Jika N(A)1 ∩ N(B)1 maka anggap sebagai sah
%                 disp('Legitimate');
%             elseif strcmp(A, NAk{1}) && strcmp(B, NBk{2})
%                 % Jika N(A)1 ∩ N(B)2 maka anggap sebagai sah
%                 disp('Legitimate');
%             else
% %                 % Jika tidak, anggap sebagai berbahaya dan tambahkan A dan B ke M
% %                 if ~isempty(M) && ~any(contains(M, A)) && ~any(contains(M, B))
% %                     M = [M, A, B];
% %                 elseif isempty(M)
% %                     M = [M, A, B];
% %                 end
% %                 % Broadcast M
% %                 disp(['Node A: ', A, ' Node B: ', B, ' Broadcast M: ', strjoin(M, ', ')]);
%             end
%         end
%     end
% end
% 
% % Tampilkan hasil
% disp('Daftar sensor berbahaya:');
% disp(M);

