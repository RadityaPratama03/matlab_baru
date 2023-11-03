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

====================================================================



%     % AODV Routing Algorithm Simulation
%     x = 1:20;
%     s1 = x(1);
%     d1 = x(20);
%     
%     % Initialize distance matrix representing distances between nodes
%     xy_array = rand(20);
%     for i = 1:20
%         for j = 1:20
%             if i == j
%                 xy_array(i, j) = 0;
%             else
%                 xy_array(j, i) = xy_array(i, j);
%             end
%         end
%     end
%     
%     t = 1:20;
%     
%     status(1) = '!';
%     dist(2) = 0;
%     next(1) = 0;
%     
%     for i = 2:20
%         status(i) = '?';
%         dist(i) = xy_array(i, 1);
%         next(i) = 1;
%     end
%     
%     flag = 0;
%     
%     % Check if Node 1 can directly reach Node 20
%     for i = 2:20
%         if xy_array(1, i) == 1
%             disp(['Node 1 sends RREQ to node ' num2str(i)]);
%             if i == 20 && xy_array(1, i) == 1
%                 flag = 1;
%             end
%         end
%     end
%     
%     disp(['Flag = ' num2str(flag)]);
%     
%     while (1)
%         if flag == 1
%             break;
%         end
%         temp = 0;
%     
%         % Find the node with the smallest distance
%         for i = 1:20
%             if status(i) == '?'
%                 D = dist(i);
%                 vert = i;
%                 break;
%             end
%         end
%     
%         for i = 1:20
%             if D > dist(i) && status(i) == '?'
%                 D = dist(i);
%                 vert = i;
%             end
%         end
%     
%         status(vert) = '!';
%     
%         for i = 1:20
%             if status() == '!'
%                 temp = temp + 1;
%             end
%         end
%     
%         if temp == 20
%             break;
%         end
%     end
%     
%     i = 20;
%     count = 1;
%     route(count) = 20;
%     
%     while next(i) ~= 1
%         disp(['Node ' num2str(i) ' sends RREP message to node ' num2str(next(i))]);
%         i = next(i);
%         count = count + 1;
%         route(count) = i;
%     end
%     
%     disp([ 'Node ' num2str(i) ' sends RREP to node 1']);
%     disp('Node 1');
%     
%     for i = count: -1:1
%         disp([ 'Sends message to node ' num2str(route(i))]);
%     end