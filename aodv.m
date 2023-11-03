xi = x;
yi = y;

% Menghitung s1
s1 = [xi(1), yi(1)];

% Menghitung min_d1
min_d1 = zeros(size(xi));  % Inisialisasi array min_d1
for i = 2:numel(xi)  % Mulai dari 2 karena kita menghitung dari elemen kedua
    min_d1(i) = sqrt((xi(i) - xi(i-1))^2 + (yi(i) - yi(i-1))^2);
end

% Matriks xy_array
t = 20; % Ganti sesuai kebutuhan
xy_array = zeros(t); % Membuat matriks t x t dengan semua elemen 0

for i = 1:t
    for j = 1:t
        if i == j
            xy_array(i, j) = 0;
        else
            xy_array(i, j) = xy_array(j, i);
        end
    end
end

disp(xy_array);

t = 1:20;
disp(t);

status = cell(1, 20);  % Gunakan cell array untuk status
dist = zeros(1, 20);   % Jarak awal
next = ones(1, 20);    % Inisialisasi seluruh next ke 1

status{1} = '!';  % Inisialisasi status node 1
dist(1) = 0;      % Inisialisasi jarak node 1
next(1) = 0;      % Inisialisasi node selanjutnya node 1

for i = 2:20
    status{i} = '?';       % Inisialisasi status node-node lain
    dist(i) = xy_array(i, 1);  % Inisialisasi jarak awal
end

flag = 0;
rreq_route = zeros(1, 20);  % Rute untuk RREQ
rreq_route_count = 0;

for i = 2:20
    if xy_array(1, i) == 1
        disp([' Node 1 sends RREQ to node ' num2str(i)]);
        rreq_route_count = rreq_route_count + 1;
        rreq_route(rreq_route_count) = i;
        if i == 20 && xy_array(1, i) == 1
            flag = 1;
        end
    end
end

disp(['Flag = ' num2str(flag)]);
for vert = 1:20
    if flag == 1
        break;
    end
    
    temp = 0;

    % Menemukan node dengan status '?'
    for i = 1:20
        if strcmp(status{i}, '?')
            D = dist(i);  % Salah, seharusnya D diinisialisasi di sini
            vert = i;
            break;
        end
    end

    % Memeriksa node lain dengan status '?' dan jarak minimum
    for i = 1:20
        if strcmp(status{i}, '?') && dist(i) < D
            D = dist(i);
            vert = i;
        end
    end

    status{vert} = '!';

    % Menghitung berapa banyak node yang statusnya '!'
    for i = 1:20
        if strcmp(status{i}, '!')
            temp = temp + 1;
        end
    end

    if temp == 20
        break;
    end

    for i = 2:20
        next(i) = 0;  % Inisialisasi node-node lainnya
        if xy_array(vert, i) == 1 && strcmp(status{i}, '?')
            disp([' Node ' num2str(vert) ' sends RREQ to node ' num2str(i)]);
            rreq_route_count = rreq_route_count + 1;
            rreq_route(rreq_route_count) = i;
            % Perbarui jarak dan node selanjutnya jika menemukan rute yang lebih baik
            if D + xy_array(vert, i) < dist(i)
                dist(i) = D + xy_array(vert, i);
                next(i) = vert;
            end
        end
    end
end

% Membuat array untuk menyimpan rute
route = zeros(1, 20);

% Menemukan rute dari node 1 ke node 20
count = 1;
i = 1; % Mulai dari node 1

while i ~= 20
    route(count) = i;
    
    % Mencari node selanjutnya dalam rute
    i = next(i);
    
    count = count + 1;
    
    if i == 0
        disp('Tidak ditemukan rute ke node tujuan.');
        break;
    end
end

% Menambahkan node 20 ke rute RREP
route(count) = 20;

% Menampilkan rute dalam urutan yang diinginkan
disp('Rute yang diinginkan:');
for j = 1:count
    disp(['Node ' num2str(route(j))]);
end

route(count + 1) = 1;  % Menambahkan node 1 ke rute RREP

disp(' Node 1 ');
for i = count + 1: -1:1
    disp([ ' Sends message to node ' num2str(route(i))]);
end

% Menampilkan rute RREQ
disp('Rute RREQ:');
for i = 1:rreq_route_count
    disp([' Node ' num2str(rreq_route(i))]);
end

% Menampilkan rute RREP
disp('Rute RREP:');
for i = count + 1:-1:1
    disp([' Node ' num2str(route(i))]);
end