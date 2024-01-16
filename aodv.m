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

%     % Tambahkan kondisi untuk keluar dari loop
%     if t >= height(data)
%         break; 
%     end
end

% Inisialisasi variabel baru untuk menyimpan data
group = table('Size', [100, 1], ...
    'VariableTypes', {'cell'}, ...
    'VariableNames', {'Result'});

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
end

% Iterasi untuk t = 1 hingga 100
for t = 1:100
    % Mengambil tabel dari dalam cell array
    resultTableTime = group.Result{t};

    % Menambahkan kolom warna ke dalam tabel hanya jika d > 0
    resultTableTime.color = cell(height(resultTableTime), 1);

    % Temukan indeks baris dengan nilai d terkecil dan terbesar
    minD = find(resultTableTime.d == min(resultTableTime.d(resultTableTime.d > 0)), 1, 'first');
    maxD = find(resultTableTime.d == max(resultTableTime.d(resultTableTime.d > 0)), 1, 'first');

    % Berikan warna hijau untuk nilai d terkecil jika d > 0
    if ~isempty(minD)
        resultTableTime.color{minD} = 'green';
    end

    % Berikan warna merah untuk nilai d terbesar jika d > 0
    if ~isempty(maxD)
        resultTableTime.color{maxD} = 'red';
    end

%     % Isi nilai 0 untuk seluruh baris yang tidak memiliki warna hijau atau merah
%     resultTableTime.color(cellfun('isempty', resultTableTime.color)) = {0};

    % Menyimpan tabel yang telah dimodifikasi ke dalam cell array
    group.Result{t} = resultTableTime;
end





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
% 
