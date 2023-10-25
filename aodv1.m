% Tentukan jarak komunikasi (Anda dapat menyesuaikan nilai ini)
communication_range = 30;

% Inisialisasi variabel-variabel
xy_array = rand(50);
A = zeros(20);  % Inisialisasi matriks ketetanggaan
status = char(zeros(1, 20));  % Inisialisasi array status
dist = zeros(1, 20);  % Inisialisasi array jarak
next = zeros(1, 20);  % Inisialisasi array next hop

s1 = 1;  % Node sumber
d1 = 20;  % Node tujuan (saya mengganti d1 menjadi 20)

% Hitung jarak dan inisialisasi status serta array jarak
for i = 1:20
    for j = 1:20
        if i == j
            A(i, j) = 0;
        else
            % Hitung jarak Euklides antara node (i, j)
            jarak = norm(xy_array(i, :) - xy_array(j, :));
            if jarak <= communication_range
                A(i, j) = jarak;
            else
                A(i, j) = Inf;  % Setel ke tak hingga jika node berada di luar jangkauan
            end
        end
    end
    
    status(i) = '?';
    dist(i) = A(i, s1);
    next(i) = s1;
end

flag = 0;

% Kirim pesan RREQ dari node 1 untuk menemukan rute
for i = 2:20
    if A(s1, i) <= communication_range
        disp(['Node 1 mengirimkan RREQ ke node ' num2str(i)]);
        if i == d1
            flag = 1;
        end
    end
end

disp(['Flag = ' num2str(flag)]);

while flag == 0
    temp = 0;
    
    % Cari node dengan jarak minimum dengan status '?'
    for i = 1:20
        if status(i) == '?' && dist(i) < min
            min = dist(i);
            vert = i;
        end
    end
    status(vert) = '!';

    % Hitung jumlah node dengan status '!'
    for i = 1:20
        if status(i) == '!'
            temp = temp + 1;
        end
    end
    
    if temp == 20
        break;
    end
end

i = d1;
count = 1;
route = zeros(1, 20);
route(count) = d1;

% Ikuti rute dan kirim pesan RREP
while next(i) ~= s1
    disp(['Node ' num2str(i) ' mengirimkan pesan RREP ke node ' num2str(next(i))]);
    i = next(i);
    count = count + 1;
    route(count) = i;
end

disp(['Node ' num2str(i) ' mengirimkan pesan RREP ke node 1']);
disp('Node 1');

%     % Kirim pesan sepanjang rute
 for i = count:-1:1
    disp(['Mengirimkan pesan ke node ' num2str(route(i))]);
 end