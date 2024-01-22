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

%figure; % Membuat figure baru

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
result = table('Size', [80, 5], ...
    'VariableTypes', {'double', 'double', 'string', 'double', 'double'}, ...
    'VariableNames', {'t', 'd', 'id', 'x', 'y'});

% Inisialisasi matriks untuk menyimpan jarak antar titik
% jarakAntarTitik = zeros(maxIterations, maxIterations);

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

%     % Menyimpan jarak antar titik ke dalam matriks
%     jarakAntarTitik(t-1, t) = d;
%     jarakAntarTitik(t, t-1) = d;

%     % Tambahkan kondisi untuk keluar dari loop
%     if t >= height(data)
%         break; 
%     end
end

% Inisialisasi variabel baru untuk menyimpan data
group = table('Size', [100, 1], ...
    'VariableTypes', {'cell'}, ...
    'VariableNames', {'Result'});

% Inisialisasi daftar sensor berbahaya
M = {};

% Iterasi untuk t = 1 hingga 100
for t = 1:100
    % Mengambil data dengan nilai 't' sesuai iterasi
    resultTime = result(result.t == t, :);

    % Perhitungan nilai d
    if t > 1
        d = sqrt((data.x(t) - data.x(t-1)).^2 + (data.y(t) - data.y(t-1)).^2);
    else
        d = 0; 
    end
    
    % Jika data tidak mencapai 80 baris, tambahkan baris dengan nilai 0
    if size(resultTime, 1) < 80
        rowsTotal = 80 - size(resultTime, 1);
        rowsZero = array2table(zeros(rowsTotal, width(resultTime)), 'VariableNames', resultTime.Properties.VariableNames);
        resultTime = [resultTime; rowsZero];
    end

    % Simpan resultTime ke dalam group
    group.Result{t} = resultTime;

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
    minD = find(resultTableTime.d > 0, 1, 'first');
    maxD = find(resultTableTime.d > 0, 1, 'last');

    % Berikan warna hijau untuk nilai d terkecil jika d > 0
    if ~isempty(minD)
        resultTableTime.color{minD} = 'green';
    end
    
    % Berikan warna merah untuk nilai d terbesar jika d > 300
    if ~isempty(maxD) && max(resultTableTime.d) > 300
        resultTableTime.color{maxD} = 'red';
    end
    
    % Isi nilai biru hanya untuk baris dengan nilai d sama dengan 0
    zeroDIdx = find(resultTableTime.d == 0);
    resultTableTime.color(zeroDIdx) = {'blue'};
    
    % Isi nilai biru untuk baris dengan nilai d tidak sama dengan 0 dan tidak memiliki warna
    nonZeroDIdx = find(resultTableTime.d > 0 & cellfun('isempty', resultTableTime.color));
    resultTableTime.color(nonZeroDIdx) = {'blue'};
    
    % Isi nilai biru hanya untuk baris dengan nilai d = 0 dan berwarna 'blue'
    zeroDIdx = find(resultTableTime.d == 0 & strcmp(resultTableTime.color, 'blue'));
    resultTableTime.color(zeroDIdx) = {[0]};

    % Menyimpan indeks baris dengan nilai d terkecil sebagai Head Cluster (warna hijau)
    headClusterIdx = find(strcmp(resultTableTime.color, 'green'));
    if ~isempty(headClusterIdx)
        resultTableTime.color{headClusterIdx} = 'Head Cluster';
    end

    % Menyimpan tabel yang telah dimodifikasi ke dalam cell array
    group.Result{t} = resultTableTime;

    % Melakukan pengecekan untuk sensor berbahaya
    if t + 1 <= 120
        % Mengambil tabel dari saat ini dan tabel dari iterasi berikutnya
        resultTableTimeCurrent = group.Result{t};
        resultTableTimeNext = group.Result{t + 1};

        % Mendapatkan N(A)k dan N(B)k dari tabel saat ini dan berikutnya
        N_Ak = unique(resultTableTimeCurrent.id);
        N_Bk = unique(resultTableTimeNext.id);

        % Pengecekan untuk setiap node A dan node B yang berdekatan
        for i = 1:numel(N_Ak)
            A = N_Ak{i};
            for j = 1:numel(N_Bk)
                B = N_Bk{j};
                
                % Jika N(A)1 ∩ N(B)1 atau N(A)1 ∩ N(B)2, maka Sah, selain itu Malicious
                if ismember(A, resultTableTimeCurrent.id) && ismember(B, resultTableTimeNext.id)
                    if numel(intersect(N_Ak, N_Bk)) > 0
                        disp('Sah');
                    else
                        disp('Malicious');
                        % Tambahkan A dan B ke M
                        M = unique([M, A, B]);
                        % Broadcast M
                        disp(['Broadcast M: ', strjoin(M, ', ')]);
                    end
                end
            end
        end
    end

    % Hapus variabel yang tidak ingin ditampilkan di workspace
    clear nonZeroDIdx zeroDIdx;
    clear headClusterIdx maxD minD;
end


% Inisialisasi warna untuk plotting
warna = {'blue', 'red', 'green', 'black', 'cyan', 'magenta', 'yellow', 'white'};

% Membuat satu figur
figure;

% Membuat plot untuk setiap nilai t dari 1 hingga 20
for t = 1:100
    % Mengambil tabel dari dalam cell array
    resultTableTime = group.Result{t};
    
    % Membuat plot (digunakan 'hold on' hanya pada iterasi pertama)
    if t == 1
        hold on;
    else
        % Membersihkan figur sebelum memplot iterasi berikutnya
        clf;
        hold on;
    end
    
    % Plot data dengan warna sesuai dengan kolom 'color'
    for i = 1:height(resultTableTime)
        if strcmp(resultTableTime.color{i}, 'Head Cluster')
            plot(resultTableTime.x(i), resultTableTime.y(i), 'X', 'Color', 'green', 'MarkerSize', 15);
        elseif strcmp(resultTableTime.color{i}, 'blue')
            plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'blue', 'MarkerSize', 10);
        elseif strcmp(resultTableTime.color{i}, 'red')
            plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'red', 'MarkerSize', 10);
        else
            plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', warna{mod(i, length(warna)) + 1}, 'MarkerSize', 10);
        end
    end
    
    % Menambahkan garis yang menghubungkan node berdasarkan nilai d pada t saat ini
    for i = 1:height(resultTableTime)-1
        d = resultTableTime.d(i);
        
        % Hanya gambar garis jika nilai d kurang dari atau sama dengan 300
        if d <= 300
            plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'k--', 'LineWidth', 1);
        end
        
        % Tambahkan teks jarak jika diperlukan
%         text((resultTableTime.x(i) + resultTableTime.x(i+1)) / 2, (resultTableTime.y(i) + resultTableTime.y(i+1)) / 2, sprintf('d=%.2f', d), 'Color', 'k', 'FontSize', 8);
    end
    
    % Menambahkan judul dan label pada plot
    title(['Plot Data untuk t = ' num2str(t)]);
    xlabel('X');
    ylabel('Y');
    grid on;
    
    % Menunggu sebentar agar perubahan posisi terlihat
    pause(1.0);
    
    hold off;
end









% % Inisialisasi matriks A untuk digunakan dalam AODV
% A = zeros(80);  % Ganti 80 dengan ukuran yang sesuai
% 
% % Menjalankan AODV
% x = 1:20;
% s1 = x(1);
% d1 = x(20);
% 
% status(1) = '!';
% dist(2) = 0;
% next(1) = 0;
% 
% for i = 2:20
%     status(i) = '?';
%     dist(i) = A(i, 1);
%     next(i) = 1;
% end
% 
% flag = 0;
% for i = 2:20
%     if A(1, i) == 1
%         disp([' node 1 sends RREQ to node ' num2str(i)])
%         if i == 20 && A(1, i) == 1
%             flag = 1;
%         end
%     end
% end
% disp(['Flag= ' num2str(flag)]);
% 
% while (1)
% 
%     if flag == 1
%         break;
%     end
% 
%     temp = 0;
%     for i = 1:20
%         if status(i) == '?'
%             min = dist(i);
%             vert = i;
%             break;
%         end
%     end
% 
%     for i = 1:20
%         if min > dist(i) && status(i) == '?'
%             min = dist(i);
%             vert = i;
%         end
%     end
%     status(vert) = '!';
% 
%     for i = 1:20
%         if status() == '!'
%             temp = temp + 1;
%         end
%     end
% 
%     if temp == 20
%         break;
%     end
% end
% 
% i = 20;
% count = 1;
% route(count) = 20;
% 
% while next(i) ~= 1
%     disp([' Node ' num2str(i) 'sends RREP message to node ' num2str(next(i))])
%     i = next(i);
%     count = count + 1;
%     route(count) = i;
%     route(count) = i;
% end
% 
% disp([' Node ' num2str(i) 'sends RREP to node 1'])
% disp(' Node 1 ')
% for i = count: -1:1
%     disp([' Sends message to node ' num2str(route(i))])
% end
% 
% % Menampilkan hasil AODV ke dalam program utama
% figure;
% 
% for t = 1:25
%     resultTableTime = group.Result{t};
%     
%     if t == 1
%         hold on;
%     else
%         clf;
%         hold on;
%     end
%     
%     % Plot data dengan warna sesuai dengan kolom 'color'
%     for i = 1:height(resultTableTime)
%         if strcmp(resultTableTime.color{i}, 'Head Cluster')
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'X', 'Color', 'green', 'MarkerSize', 15);
%         elseif strcmp(resultTableTime.color{i}, 'blue')
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'blue', 'MarkerSize', 10);
%         elseif strcmp(resultTableTime.color{i}, 'red')
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'red', 'MarkerSize', 10);
%         else
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', warna{mod(i, length(warna)) + 1}, 'MarkerSize', 10);
%         end
%     end
%     
%     % Menambahkan garis yang menghubungkan node berdasarkan nilai d pada t saat ini
%     for i = 1:height(resultTableTime)-1
%         d = resultTableTime.d(i);
%         plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'k--', 'LineWidth', 1);
%     end
%     
%     % Menambahkan marker untuk menunjukkan hasil AODV (misalnya, marker berbeda untuk RREQ dan RREP)
%     markerX = resultTableTime.x;
%     markerY = resultTableTime.y;
%     plot(markerX, markerY, 's', 'Color', 'magenta', 'MarkerSize', 12, 'LineWidth', 2);
% 
% 
%     title(['Plot Data untuk t = ' num2str(t)]);
%     xlabel('X');
%     ylabel('Y');
%     grid on;
%     
%     pause(1.0);
%     
%     hold off;
% end

% % Inisialisasi warna untuk plotting
% warna = {'blue', 'red', 'green', 'black', 'cyan', 'magenta', 'yellow', 'white'};
% 
% % Membuat satu figur
% figure;
% 
% % Loop melalui setiap tabel waktu dalam cell array
% for t = 1:100
%     % Mengambil tabel dari dalam cell array
%     resultTableTime = group.Result{t};
%     
%     % Membuat plot (digunakan 'hold on' hanya pada iterasi pertama)
%     if t == 1
%         hold on;
%     else
%         % Membersihkan figur sebelum memplot iterasi berikutnya
%         clf;
%         hold on;
%     end
%     
%     % Plot data dengan warna sesuai dengan kolom 'color'
%     for i = 1:height(resultTableTime)
%         if strcmp(resultTableTime.color{i}, 'Head Cluster')
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'green', 'MarkerSize', 10);
%         elseif strcmp(resultTableTime.color{i}, 'blue')
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'blue', 'MarkerSize', 10);
%         elseif strcmp(resultTableTime.color{i}, 'red')
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', 'red', 'MarkerSize', 10);
%         else
%             plot(resultTableTime.x(i), resultTableTime.y(i), 'o', 'Color', warna{mod(i, length(warna)) + 1}, 'MarkerSize', 10);
%         end
%     end
%     
%     % Menambahkan garis yang menghubungkan node berdasarkan nilai d pada t saat ini
%     for i = 1:height(resultTableTime)-1
%         d = resultTableTime.d(i);
%         plot([resultTableTime.x(i), resultTableTime.x(i+1)], [resultTableTime.y(i), resultTableTime.y(i+1)], 'k--', 'LineWidth', 1);
% %         text((resultTableTime.x(i) + resultTableTime.x(i+1)) / 2, (resultTableTime.y(i) + resultTableTime.y(i+1)) / 2, sprintf('d=%.2f', d), 'Color', 'k', 'FontSize', 8);
%     end
%     
%     % Menambahkan judul dan label pada plot
%     title(['Plot Data untuk t = ' num2str(t)]);
%     xlabel('X');
%     ylabel('Y');
%     grid on;
%     
%     % Menunggu sebentar agar perubahan posisi terlihat
%     pause(0.1);
%     
% end






%     % Kalkulasi nilai d
%     d = sqrt((data.x(t) - x).^2 + (data.y(t) - y).^2);

%     % Kalkulasi nilai d
%     d = sqrt((data.x(t) - data.x(t-1)).^2 + (data.y(t) - data.y(t-1)).^2);

% %Code : AODV Routing.
% x=1:20;
% s1=x(1);
% d1=x(20);
% clc;
% A=rand(20);
% % Making matrix all diagonals=0 and A(i,j)=A(j,i),i.e. A(1,4)=a(4,1),
% % A(6,7)=A(7,6)
% for i=1:20
%         for j=1:20
%                 if i==j
%                     A(i,j)=0;
%                 else
%                     A(j,i)=A(i,j);
%                 end
%         end
% end
% disp(A);
% t=1:20;
% disp(t);
%  
%  disp(A);
%  status(1)='!';
% % dist(1)=0;
% dist(2)=0;
%  next(1)=0;
%  
%  for i=2:20
%     
%      status(i)='?';
%      dist(i)=A(i,1);
%      next(i)=1;
%    disp(['i== ' num2str(i) ' A(i,1)=' num2str(A(i,1)) ' status:=' status(i) ' dist(i)=' num2str(dist(i))]);
%  end
%  
%  flag=0;
%  for i=2:20
%         if A(1,i)==1
%             disp([' node 1 sends RREQ to node ' num2str(i)])
%                 if i==20 && A(1,i)==1
%                        flag=1;
%                 end
%         end
%  end
%  disp(['Flag= ' num2str(flag)]);
%  while(1)
%      
%     if flag==1
%             break;
%     end
%     
%     temp=0;
%     for i=1:20
%         if status(i)=='?'
%             min=dist(i);
%             vert=i;
%             break;
%         end
%     end
%     
%     for i=1:20
%         if min>dist(i) && status(i)=='?'
%             min=dist(i);
%             vert=i;
%         end
%     end
%     status(vert)='!';
%     
%     for i=1:20
%         if status()=='!'
%             temp=temp+1;
%         end
%     end
%     
%     if temp==20
%         break;
%     end
%  end
%   
%  i=20;
%  count=1;
%  route(count)=20;
%  
%  while next(i) ~=1
%      disp([' Node ' num2str(i) 'sends RREP message to node ' num2str(next(i))])
%      i=next(i);
%      %disp(i);
%      count=count+1;
%      route(count)=i;
%      route(count)=i;
%  end
%  
%  disp([ ' Node ' num2str(i) 'sends RREP to node 1'])
%  disp(' Node 1 ')
%  for i=count: -1:1
%      disp([ ' Sends message to node ' num2str(route(i))])
%  end

