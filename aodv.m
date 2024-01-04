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
% r = str2double(strrep(data.id, 'f_', ''));

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
t = 0;

% Inisialisasi variabel baru untuk menyimpan data
groupTableTime = cell(100, 1);

% Maksimum iterasi yang diinginkan
maxIterations = 80;

% Inisialisasi tabel untuk menyimpan hasil
resultTable = table('Size', [80, 5], ...
    'VariableTypes', {'double', 'double', 'string', 'double', 'double'}, ...
    'VariableNames', {'t', 'd', 'id', 'x', 'y'});

while (t + 1) <= maxIterations
    % Increment t
    t = t + 1;

%     % Kalkulasi nilai d hanya untuk titik tertentu
%     d = sqrt((data.x(t) - data.x(t- 1)).^2 + (data.y(t) - data.y(t- 1)).^2);

    % Kalkulasi nilai d
    if t == 1
        % Penanganan iterasi pertama
        d = 0;
    else
        % Kalkulasi nilai d hanya untuk titik tertentu
        d = sqrt((data.x(t) - data.x(t-1)).^2 + (data.y(t) - data.y(t-1)).^2);
    end

    % Menyimpan nilai t, d, id, x, dan y ke dalam resultTable
    resultTable.t(t) = data.time(t);
    resultTable.d(t) = d;
    resultTable.id{t} = data.id{t};
    resultTable.x(t) = data.x(t);
    resultTable.y(t) = data.y(t);

    % Tambahkan kondisi untuk keluar dari loop
    if t >= height(data)
        break; % Keluar dari loop jika t mencapai atau melebihi jumlah baris data
    end
end

% Iterasi untuk t = 0 hingga 100
for t = 0:100
    % Mengambil data dengan nilai 't' sesuai iterasi
    resultTableTime = resultTable(resultTable.t == t, :);
    
    % Jika data tidak mencapai 80 baris, tambahkan baris dengan nilai 0
    if size(resultTableTime, 1) < maxIterations
        rowsTotal = maxIterations - size(resultTableTime, 1);
        rowsZero = array2table(zeros(rowsTotal, width(resultTableTime)), 'VariableNames', resultTableTime.Properties.VariableNames);
        resultTableTime = [resultTableTime; rowsZero];
    end

    % Kalkulasi nilai d
    if t == 0
        % Penanganan iterasi pertama
        d = 0;
    else
        % Kalkulasi nilai d hanya untuk titik tertentu
        d = sqrt((data.x(t+1) - data.x(t)).^2 + (data.y(t+1) - data.y(t)).^2);
    end

    % Menyimpan nilai t, d, id, x, dan y ke dalam resultTableTime
    resultTableTime.t(t+1) = data.time(t+1);
    resultTableTime.d(t+1) = d;
    resultTableTime.id{t+1} = data.id{t+1};
    resultTableTime.x(t+1) = data.x(t+1);
    resultTableTime.y(t+1) = data.y(t+1);

    % Simpan resultTableTime ke dalam groupTableTime
    groupTableTime{t+1} = resultTableTime;

    % Jika Anda ingin menggunakan nilai minimum dari d, tambahkan logika yang sesuai di sini
%     mind = min(d, mind);
end

% % Iterasi untuk t = 1 hingga 100
% for t = 0:100
%     % Mengambil data dengan nilai 't' sesuai iterasi
%     resultTableTime = resultTable(resultTable.d ~= 0, :);
%     
%     % Jika data tidak mencapai 80 baris, tambahkan baris dengan nilai 0
%     if height(resultTableTime) < maxIterations
%         rowsTotal = maxIterations - height(resultTableTime);
%         rowsZero = array2table(zeros(rowsTotal, width(resultTable)), 'VariableNames', resultTable.Properties.VariableNames);
%         resultTableTime = [resultTableTime; rowsZero];
%     end
% 
%     % Kalkulasi nilai d
%     if t == 0
%         % Penanganan iterasi pertama
%         d = 0;
%     else
%         % Kalkulasi nilai d hanya untuk titik tertentu
%         d = sqrt((data.x(t+1) - data.x(t)).^2 + (data.y(t+1) - data.y(t)).^2);
%     end
% 
%     % Menyimpan nilai d, id, x, dan y ke dalam resultTableTime
%     resultTableTime.d(t+1) = d;
%     resultTableTime.id{t+1} = data.id{t+1};
%     resultTableTime.x(t+1) = data.x(t+1);
%     resultTableTime.y(t+1) = data.y(t+1);
% 
%     % Simpan resultTableTime ke dalam groupTableTime
%     groupTableTime{t+1} = resultTableTime;
% 
%     % Jika Anda ingin menggunakan nilai minimum dari d, tambahkan logika yang sesuai di sini
%     % mind = min(d, mind);
% end

    % Kalkulasi nilai d
%     d = sqrt((data.x(t) - x).^2 + (data.y(t) - y).^2);

%     % Kalkulasi nilai d
%     d = sqrt((data.x(t) - data.x(t-1)).^2 + (data.y(t) - data.y(t-1)).^2);




%     % Menyimpan nilai t, d, id, x, dan y ke dalam resultTable
%     resultTable.t(t) = data.time(t);
%     resultTable.d(t) = d;
%     resultTable.id{t} = data.id{t};
%     resultTable.x(t) = data.x(t);
%     resultTable.y(t) = data.y(t);

% % Membuat variabel baru untuk menyimpan data t per detik
% resultTable = table('Size', [80, 4], ...
%     'VariableTypes', {'double', 'string', 'double', 'double'}, ...
%     'VariableNames', {'d', 'id', 'x', 'y'});
% 
% % Inisialisasi indeks t
% t = 0; % Ubah inisialisasi menjadi 0
% 
% % Maksimum iterasi yang diinginkan
% maxIterations = 80;
% 
% while (t + 1) <= maxIterations
%     % Increment t
%     t = t + 1;
% 
%     % Kalkulasi nilai d
%     d = t * (t - 1) / 2;
% 
%     % Menyimpan nilai d, id, x, dan y ke dalam resultTable
%     resultTable.d(t) = d;
%     resultTable.id{t} = data.id{t};
%     resultTable.x(t) = data.x(t);
%     resultTable.y(t) = data.y(t);
% end




% % Filter data 
% % selectedData = data(ismember(data.type, Data_p), {'id', 'x', 'y' });
% selectedData = data(:, {'id', 'x', 'y'});
% 
% % Ukuran selectedData 80
% selectedData = selectedData(1:80, :);

% % Inisialisasi selectedData dengan zeros
% selectedData = zeros(80, 3);
% 
% % Mengisi elemen dengan data dari x, y, dan r
% selectedData(:, 1) = data.x(80:-1:1);
% selectedData(:, 2) = data.y(80:-1:1);
% selectedData(:, 3) = data.id(80:-1:1);
% 
% % Inisialisasi cell array resultTable
% resultTable = cell(80, 4);
% 
% % Inisiasi indeks t
% t = 1;
% 
% % Loop while dengan penambahan indeks t
% while t <= t + 1
%     % Kalkulasi nilai d
%     d = t * (t - 1) / 2;
% 
%     % Tambahkan nilai d, x, y, dan id ke dalam resultTable
%     resultTable{t, 1} = d;
%     resultTable{t, 2} = selectedData(t, 1);
%     resultTable{t, 3} = selectedData(t, 2);
%     resultTable{t, 4} = selectedData(t, 3);
% end
% 
% % Tampilkan hasil
% disp(resultTable);



% % Menghitung min_d1
% min_d1 = zeros(size(selectedData, 1), 1);
% for i = 2:size(selectedData, 1)
%     % Mengakses nilai kolom 'x' dan 'y' dari tabel
%     x1 = selectedData.x(i);
%     y1 = selectedData.y(i);
%     
%     x2 = selectedData.x(i-1);
%     y2 = selectedData.y(i-1);
%     
%     % Menghitung jarak Euclidean antara dua titik
%     min_d1(i) = sqrt((x1 - x2)^2 + (y1 - y2)^2);
% end

% % Inisialisasi resultMatrix sebagai cell array
% resultMatrix = cell(size(selectedData, 1), 4);
% 
% % Loop while dengan penambahan indeks t
% while t <= size(selectedData, 1)
%     % Kalkulasi nilai d
%     d = t * (t - 1) / 2;
% 
%     % Menambahkan nilai d, x, y, dan id ke dalam resultMatrix
%     resultMatrix{t, 1} = d;
%     resultMatrix{t, 2} = selectedData.id{t};
%     resultMatrix{t, 3} = selectedData.x(t);
%     resultMatrix{t, 4} = selectedData.y(t);
% 
%     % Tambahkan indeks t
%     t = t + 1;
% end


% % Loop while dengan penambahan indeks t
% while t <= size(selectedData, 1)
%     % Kalkulasi nilai d
%     d = t * (t - 1) / 2;
% 
%     % Menambahkan nilai d, x, y, dan id ke dalam resultMatrix
%     resultMatrix(t, :) = [d,string(selectedData.id{t}), selectedData.x(t), selectedData.y(t) ];
% 
%     % Tambahkan indeks t
%     t = t + 1;
% end

% % Menghitung min_d1
% min_d1 = zeros(size(selectedData, 1), 1);
% for i = 2:size(selectedData, 1)
%     min_d1(i) = sqrt((selectedData(i, 2) - selectedData(i-1, 2))^2 + (selectedData(i, 3) - selectedData(i-1, 3))^2);
% end

% % Memasukkan data ke dalam variabel xi, yi, id, dan t
% xi = x; 
% yi = y;
% id = r;
% ti = t;
% 
% % Menggabungkan data ke dalam satu tabel
% data_table = table(ti, id, xi, yi, 'VariableNames', {'t', 'id', 'xi', 'yi'});
% 
% % Sel untuk menyimpan data pada setiap waktu
% selectedDataCell = cell(0, 100); % Sesuaikan dengan jumlah waktu yang diinginkan, misalnya, 100
% 
% % Iterasi untuk setiap nilai t dari 0 hingga 100
% for t = 0:100
%     % Mencari data yang sesuai dengan nilai t pada tabel
%     data_t = data_table(data_table.t == t, :);
% 
% %     % Inisialisasi matriks zeros dengan ukuran sesuai jumlah baris di data
% %     selectedData = zeros(height(data_table), 3);
% 
%     % Inisialisasi matriks zeros dengan ukuran sesuai jumlah baris di data
%     selectedData = zeros(1, 3);
% 
%     % Mengisi matriks dengan nilai dari kolom id, xi, dan yi ketika t = 0 atau t = 1
%     if ~isempty(data_t)
%         % Jika t bukan 0, pindahkan data ke baris pertama
%         if t > 0
%             selectedData(1:size(data_t, 1), :) = [str2double(strrep(data_t.id, 'f_', '')), data_t.xi, data_t.yi];
%         else
%             selectedData(data_table.t == t, :) = [str2double(strrep(data_t.id, 'f_', '')), data_t.xi, data_t.yi];
%         end
%     end
%     
%     % Menetapkan nilai 0 untuk baris berikutnya setelah t sekian
%     selectedData(data_table.t > t, :) = 0;
% 
%     % Menyimpan hasil pada sel yang sesuai dengan nilai t
%     selectedDataCell = selectedData;
% end
% 
% % Menghitung d polinomial
% d =  t .* (t - 1) / 2;
% 
% % Menghitung min_d1
% min_d1 = zeros(size(selectedData, 1), 1);
% for i = 2:size(selectedData, 1)
%     min_d1(i) = sqrt((selectedData(i, 2) - selectedData(i-1, 2))^2 + (selectedData(i, 3) - selectedData(i-1, 3))^2);
% end


% % Menggabungkan data ke dalam satu tabel
% data_table = table(ti, id, xi, yi, 'VariableNames', {'t', 'id', 'xi', 'yi'});
% 
% % Sel untuk menyimpan data pada setiap waktu
% selectedDataCell = cell(0, 100); % Sesuaikan dengan jumlah waktu yang diinginkan, misalnya, 100
% 
% % Iterasi untuk setiap nilai t dari 0 hingga 100
% for t = 0:100
%     % Mencari data yang sesuai dengan nilai t pada tabel
%     data_t = data_table(data_table.t == t, :);
% 
%     % Inisialisasi matriks zeros dengan ukuran sesuai jumlah baris di data
%     selectedData = zeros(height(data_table), 3);
% 
%     % Mengisi matriks dengan nilai dari kolom id, xi, dan yi ketika t = 0 atau t = 1
%     if ~isempty(data_t)
%         % Jika t bukan 0, pindahkan data ke baris pertama
%         if t > 0
%             selectedData(1:size(data_t, 1), :) = [str2double(strrep(data_t.id, 'f_', '')), data_t.xi, data_t.yi];
%         else
%             selectedData(data_table.t == t, :) = [str2double(strrep(data_t.id, 'f_', '')), data_t.xi, data_t.yi];
%         end
%     end
% 
%     % Menetapkan nilai 0 untuk baris berikutnya setelah t sekian
%     selectedData(data_table.t > t, :) = 0;
% 
%     % Menyimpan hasil pada sel yang sesuai dengan nilai t
%     selectedDataCell{t + 1} = selectedData;
% end



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
% 
