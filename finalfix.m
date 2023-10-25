filename = 'Hsimulasi.xlsx';
sheet = 'Sheet2';
data = readtable(filename, 'Sheet', sheet);

t = data.time;
x = data.x;
y = data.y;
l = data.lane;
p = data.type;
a = data.angle;
s = data.speed;

K = 30; % Konstanta berbeda setiap lingkungan

start1 = 1;

figure; % Membuat figure baru

subplot(5, 1, 1);
axis([-50 350 -40 120]);
title('Jalur PKU');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

subplot(5, 1, 2); % Subplot untuk menghitung reachable
%axis('auto');
axis([10 inf 0 inf]);
title('TraceCount Reachable');
xlabel('Jumlah Kendaraan');
ylabel('Duration (s)');
grid on;
hold on;

subplot(5, 1, 3);
axis([-50 350 -40 120]);
title('Jalur PKU Cluster');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

subplot(5, 1, 4);
axis([-50 350 -40 120]);
title('Reachable (Hijau) dan Unreachable (Merah)');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

subplot(5, 1, 5);
axis([-50 350 -40 120]);
title('Jalur PKU Serangan Wormhole');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

Data_t = unique(t);
Data_p = unique(p);
Data_l = unique(l);
xy_array = [];
traceCount = [];
reachableDuration = [];

for i = 1:length(Data_t)
    subplot(5, 1, 1);
    cla;
    idx = t == Data_t(i);
    xy_array = [x(idx), y(idx)];
    distance1 = sqrt((xy_array(:, 1).^2) + (xy_array(:, 2).^2));
    % Memisahkan data berdasarkan jenis kendaraan
    idx_mobil = idx & strcmp(p, 'mobil');
    idx_taxi = idx & strcmp(p, 'taxi');
 
    % Plot titik koordinat mobil dengan warna hijau
    plot(x(idx_mobil), y(idx_mobil), 'o', 'MarkerFaceColor', 'Green');
    hold on;

    % Plot titik koordinat taksi dengan warna merah
    plot(x(idx_taxi), y(idx_taxi), 'o', 'MarkerFaceColor', 'Red');
    hold on;

    % Plot titik koordinat RSU 
    rsu_x = 119.797421731123;
    rsu_y = 50.2803738317757;
    text(rsu_x, rsu_y, 'RSU', 'HorizontalAlignment', 'left')
    plot(rsu_x, rsu_y, 'o', 'MarkerFaceColor', 'cyan');
    hold on;

    % Menghubungkan dua titik koordinat dengan garis berdasarkan nilai unik pada Data_l
    for j = 1:length(Data_l)
        idx_l = idx & strcmp(l, Data_l(j));
        x_l = x(idx_l);
        y_l = y(idx_l);

        % Menggambar garis yang menghubungkan titik terdekat
        for k = 1:length(x_l)-1
            % Menghitung jarak antara dua titik
            distance2 = sqrt((x_l(k+1) - x_l(k))^2 + (y_l(k+1) - y_l(k))^2);

            % Memilih warna berdasarkan jarak
            if distance2 <= 30
                line_color = 'green'; % Warna hijau untuk jarak <= 30 meter
            elseif distance2 <= 50
                line_color = 'red'; % Warna merah untuk jarak <= 50 meter
            end

            % Menggambar garis dengan warna yang sesuai
            line1 = plot([x_l(k), x_l(k+1)], [y_l(k), y_l(k+1)], '--', 'Color', line_color);
        end

        % Menghitung jarak antara titik dengan RSU
        distance_to_rsu = sqrt((x_l - rsu_x).^2 + (y_l - rsu_y).^2);
        idx_rsu = distance_to_rsu <= 30;

        % Menggambar garis yang menghubungkan titik dengan RSU
        for k = 1:length(x_l(idx_rsu))
            line1 = plot([x_l(idx_rsu(k)), rsu_x], [y_l(idx_rsu(k)), rsu_y], '--', 'Color', 'cyan');
        end

%         % Inisialisasi matriks jarak antara setiap kendaraan ke RSU
%         distance_to_rsu_matrix = zeros(size(data, 1), 1);
%         
%         % Isi kolom "DistanceToRSU" dengan data jarak
%         for k = 1:size(data, 1)
%             distance_to_rsu = sqrt((data.x(k) - rsu_x)^2 + (data.y(k) - rsu_y)^2);
%             distance_to_rsu_matrix(k) = distance_to_rsu;
%         end
%         
%         % Tambahkan kolom baru ke dalam data
%         data.DistanceToRSU = distance_to_rsu_matrix;

        % Menambahkan kondisi "reachable" atau "unreachable"
        kondisi = cell(size(data, 1), 1);
        for k = 1:size(data, 1)
            if x(k) <= 255
                kondisi{k} = 'reachable';
            elseif y(k) <= 255
                kondisi{k} = 'unreachable';
            end
            
            % Tambahkan kondisi untuk mengubah menjadi 'unreachable' jika reachableDuration mencapai atau melebihi 20
            if k > 255 && strcmp(kondisi{k}, 'reachable')
                kondisi{k} = 'unreachable';
            end
        end
        
        % Menghitung TraceCount Reachable/Second
        traceCount = zeros(size(xy_array, 1), 1);
        reachableDuration = zeros(size(xy_array, 1), 1);
        reached = false;
        
        for k = 1:size(xy_array, 1)
            if k == 1
                if strcmp(kondisi{k}, 'reachable')
                    reachableDuration(k) = 1;
                    reached = true;
                else
                    reachableDuration(k) = 0;
                end
            else
                if strcmp(kondisi{k}, 'reachable')
                    if reached
                        reachableDuration(k) = reachableDuration(k - 1) + 1;
                    else
                        reached = true;
                        % Tetapkan reachableDuration(k) ke nilai sebelumnya + 1, atau minimal 1
                        reachableDuration(k) = max(reachableDuration(k - 1) + 1, 1);
                    end
                else
                    reached = false;
                    % Tetapkan reachableDuration(k) ke nilai sebelumnya, atau minimal 0
                    reachableDuration(k) = max(reachableDuration(k - 1), 0);
                    % Tambahkan kondisi untuk mengatur reachableDuration menjadi 0 jika data > 20
                    if k > 255 && strcmp(kondisi{k}, 'unreachable') %x(k) > 255 && y(k) > 255
                        reachableDuration(k) = 0;
                    end
                end 
            end
            traceCount(k) = k;
        end
    end
    legend('mobil','taxi', 'RSU', 'Location', 'northwest');

    % Plot untuk Duration
    subplot(5, 1, 2);
    if i <= numel(traceCount) && i <= numel(reachableDuration)
        plot(traceCount(start1:i), reachableDuration(start1:i), '-', 'Color', 'red');
    end
    hold on;
    legend('mobil&taxi', 'Location', 'northwest');

    % Plot untuk Clustering
    subplot(5, 1, 3);
    cla;
    
    % Plot titik koordinat RSU 
    rsu_x = 119.797421731123;
    rsu_y = 50.2803738317757;
    text(rsu_x, rsu_y, 'RSU', 'HorizontalAlignment', 'left')
    plot(rsu_x, rsu_y, 'o', 'MarkerFaceColor', 'cyan');
    hold on;
    
    % Menghubungkan dua titik koordinat dengan garis berdasarkan nilai unik pada Data_l
    for j = 1:length(Data_l)
        idx_l = idx & strcmp(l, Data_l(j));
        x_l = x(idx_l);
        y_l = y(idx_l);
    
        % Menggambar garis yang menghubungkan titik terdekat
        for k = 1:length(x_l)-1
            % Menghitung jarak antara dua titik
            distance2 = sqrt((x_l(k+1) - x_l(k))^2 + (y_l(k+1) - y_l(k))^2);
    
            % Memilih warna berdasarkan jarak
            if distance2 <= 30
                line_color = 'green'; % Warna hijau untuk jarak <= 30 meter
            elseif distance2 <= 50
                line_color = 'red'; % Warna merah untuk jarak <= 50 meter
            end
    
            % Menggambar garis dengan warna yang sesuai
            %line1 = plot([x_l(k), x_l(k+1)], [y_l(k), y_l(k+1)], '--', 'Color', line_color);
        end
    
        % Menghitung jarak antara titik dengan RSU
        distance_to_rsu = sqrt((x_l - rsu_x).^2 + (y_l - rsu_y).^2);
        idx_rsu = distance_to_rsu <= 30;
    
        % Menggambar garis yang menghubungkan titik dengan RSU
        for k = 1:length(x_l(idx_rsu))
            %line1 = plot([x_l(idx_rsu(k)), rsu_x], [y_l(idx_rsu(k)), rsu_y], '--', 'Color', 'cyan');
        end
    end

    % Menambahkan data speed dan normalisasi
    data_speed = data.speed; % Mengambil data speed
    
    % Menentukan rentang (range) dari data speed yang akan digunakan dalam normalisasi
    min_speed = min(data_speed);
    max_speed = max(data_speed);

    % Menambahkan data angle dan normalisasi
    data_angle = a; % Mengambil data angle 
    % Menentukan rentang (range) dari data sudut yang akan digunakan dalam normalisasi
    min_angle = min(data_angle);
    max_angle = max(data_angle);
    
    % Normalisasi data sudut 
    min_range = min(x); 
    max_range = max(x); 
    % Variable x untuk menyimpan data min_range max_range
    
    % Normalisasi data speed
    normalized_speed = min_range + ((data_speed - min_speed) / (max_speed - min_speed)) * (max_range - min_range);

    normalized_angle = min_range + ((data_angle - min_angle) / (max_angle - min_angle)) * (max_range - min_range); 
    % (data_angle - min_angle) akan menghasilkan data selisih data antara nilai angle 
    % (max_angle - min_angle akan menghasilkan data angle yang max dengan min
    
    % Menambahkan data speed ke dalam data_xy_angle
    data_xy_angle_speed = [x(idx), y(idx), normalized_angle(idx), normalized_speed(idx)];
    
    % Tambahkan label untuk data speed
    speed_label = cell(size(data, 1), 1);
    for i = 1:size(data, 1)
        speed_label{i} = sprintf('  %.2f  ', data_speed(i));
    end
   
    % Menambahkan clustering K-Medoids 
    data_xy_angle = [x(idx), y(idx), normalized_angle(idx)]; % Menggabungkan data x, data y, dan data angle yang sudah dinormalisasikan
    
    k = 4; % Jumlah cluster yang dipilih

    [idx_medoids, C, sumd, D] = kmedoids(data_xy_angle_speed, k, 'Distance', 'euclidean');
    %[idx_medoids, C, sumd, D] = kmedoids(data_xy_angle, k, 'Distance', 'euclidean'); 

    % [idx,C,sumd,D,midx] = kmedoids(___) dengan menggunakan syntax kmedoids, data dilakukan perhitungan dengan Euclidian Distance 
    % idx_medoids yang berisi indeks cluster 
    % C berisi medoid (titik pusat) dari masing-masing cluster
    % sumd berisi k yang berisi total jarak (jarak Euclidean) dari masing-masing cluster
    % D berisi matriks jarak antara setiap titik data dengan semua medoid dalam cluster
    
    % Menggambar hasil clustering dengan warna yang berbeda
    for cluster = 1:k
        %cluster_points = data_xy_angle(idx_medoids == cluster, :); % Menghitung cluster-cluster hasil dari proses k-medoids cluster
        % cluster_points berisi data yang termasuk dalam cluster
        cluster_points = data_xy_angle_speed(idx_medoids == cluster, :); % Menghitung cluster-cluster hasil dari proses k-medoids cluster
    
        if cluster == 1
            marker = 'h'; 
            color = 'blue';
        elseif cluster == 2
            marker = 's'; 
            color = 'red';
        elseif cluster == 3
            marker = '^'; 
            color = 'green';
        else
            marker = 'd'; 
            color = 'magenta';
        end

        % Menampilkan Plot cluster
        scatter3(cluster_points(:, 1), cluster_points(:, 2), cluster_points(:, 3), 50, color, marker, 'filled');
        hold on;
    
        % Menampilkan Plot medoid cluster 
        scatter3(C(cluster, 1), C(cluster, 2), C(cluster, 3), 200, color, 'X', 'LineWidth', 2);
        hold on;

        % Menambahkan label kecepatan ke plot dengan mengatur font
%         for i = 1:size(data_xy_angle_speed, 1)
%             text(data_xy_angle_speed(i, 1), data_xy_angle_speed(i, 2), data_xy_angle_speed(i, 3), speed_label{i},'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'Color', 'black', 'FontSize', 6);
%         end
    end
    
    % Menambahkan label pada plot
    xlabel('Data x');
    ylabel('Data y');
    zlabel('Normalized Angle');
    title('Hasil Clustering K-Medoids (4 Cluster)');
    
    % Menampilkan legend
    legend('RSU', 'Cluster 1', 'Medoid 1', 'Cluster 2', 'Medoid 2', 'Cluster 3', 'Medoid 3', 'Cluster 4', 'Medoid 4', 'Location', 'northwest');

    % Plot untuk Reachable dan Unreachable
    subplot(5, 1, 4);
    cla;
    
    % Plot RSU
    text(rsu_x, rsu_y, 'RSU', 'HorizontalAlignment', 'left')
    hold on;
    plot(rsu_x, rsu_y, 'o', 'MarkerFaceColor', 'cyan');
    hold on;

    % Menghubungkan dua titik koordinat dengan garis berdasarkan nilai unik pada Data_l
    for j = 1:length(Data_l)
        idx_l = idx & strcmp(l, Data_l(j));
        x_l = x(idx_l);
        y_l = y(idx_l);
        id_l = data.id(idx_l); % Kolom id dari data
        type_l = data.type(idx_l); % Kolom type dari data

        % Menghitung jarak antara titik dengan RSU
        distance_to_rsu = sqrt((x_l - rsu_x).^2 + (y_l - rsu_y).^2);
        idx_rsu = distance_to_rsu <= 30;

        % Menghitung jarak antara titik dengan RSU dan overwrite data
        distance_to_rsu = sqrt((x - rsu_x).^2 + (y - rsu_y).^2);
        data.Distance_to_RSU = distance_to_rsu;
    end

    reachable_centroid = scatter3(nan, nan, nan, 200, 'green', 'X', 'LineWidth', 2);
    unreachable_centroid = scatter3(nan, nan, nan, 200, 'red', 'X', 'LineWidth', 2);

    % Menambahkan centroid cluster dengan tanda X dan warna berdasarkan kondisi
    for cluster = 1:k
        for cluster1 = 1:k
            for cluster2 = 1:k
                if cluster1 == cluster2
                    cluster_points1 = C(cluster1, :);
                    cluster_points2 = C(cluster2, :);
                    if cluster1 ~= cluster2
                        line([cluster_points1(1), cluster_points2(1)], ...
                             [cluster_points1(2), cluster_points2(2)], ...
                             [cluster_points1(3), cluster_points2(3)], 'Color', color, 'LineStyle', '-', 'LineWidth', 2);
                    end
                end
            end
        end 
        if cluster <= size(C, 1)
            centroid_x = C(cluster, 1);
            centroid_y = C(cluster, 2);
            centroid_z = C(cluster, 3);
    
            % Menghitung jarak antara centroid dengan RSU
            distance_to_rsu = sqrt((centroid_x - rsu_x)^2 + (centroid_y - rsu_y)^2);
    
           % Plot centroid cluster dengan tanda X dan warna yang sesuai
            if distance_to_rsu <= 30
                scatter3(centroid_x, centroid_y, centroid_z, 200, 'green', 'X', 'LineWidth', 2);
                hold on;
            else
                scatter3(centroid_x, centroid_y, centroid_z, 200, 'red', 'X', 'LineWidth', 2);
                hold on;
            end
        end
    end
    
    % Tampilkan legenda
    legend('RSU', 'Headcluster Reachable', 'Headcluster Unreachable', 'Location', 'northwest');

    % Plot untuk Wormhole
    subplot(5, 1, 5);
    cla;
    plot(x(idx_mobil), y(idx_mobil), 'o', 'MarkerFaceColor', 'Green');
    hold on;
    plot(x(idx_taxi), y(idx_taxi), 'o', 'MarkerFaceColor', 'Red');
    hold on;
    text(rsu_x, rsu_y, 'RSU', 'HorizontalAlignment', 'left');
    hold on;
    plot(rsu_x, rsu_y, 'o', 'MarkerFaceColor', 'cyan');
    hold on;

    % Plot titik koordinat RSU 
    rsu_x = 119.797421731123;
    rsu_y = 50.2803738317757;
    text(rsu_x, rsu_y, 'RSU', 'HorizontalAlignment', 'left')
    plot(rsu_x, rsu_y, 'o', 'MarkerFaceColor', 'cyan');
    hold on;

    % Menghubungkan dua titik koordinat dengan garis berdasarkan nilai unik pada Data_l
    for j = 1:length(Data_l)
        idx_l = idx & strcmp(l, Data_l(j));
        x_l = x(idx_l);
        y_l = y(idx_l);

        % Menggambar garis yang menghubungkan titik terdekat
        for k = 1:length(x_l)-1
            % Menghitung jarak antara dua titik
            distance2 = sqrt((x_l(k+1) - x_l(k))^2 + (y_l(k+1) - y_l(k))^2);

            % Memilih warna berdasarkan jarak
            if distance2 <= 30
                line_color = 'green'; % Warna hijau untuk jarak <= 30 meter
            elseif distance2 <= 50
                line_color = 'red'; % Warna merah untuk jarak <= 50 meter
            end

            % Menggambar garis dengan warna yang sesuai
            line1 = plot([x_l(k), x_l(k+1)], [y_l(k), y_l(k+1)], '--', 'Color', line_color);
        end

        % Menghitung jarak antara titik dengan RSU
        distance_to_rsu = sqrt((x_l - rsu_x).^2 + (y_l - rsu_y).^2);
        idx_rsu = distance_to_rsu <= 30;

        % Menggambar garis yang menghubungkan titik dengan RSU
        for k = 1:length(x_l(idx_rsu))
            line1 = plot([x_l(idx_rsu(k)), rsu_x], [y_l(idx_rsu(k)), rsu_y], '--', 'Color', 'cyan');
        end
    end

        % Inisialisasi matriks xy_array (adjacency matrix)
    xy_array = rand(50);
    
    % Membuat matriks xy_array menjadi simetris (xy_array(i, j) = xy_array(j, i))
    xy_array = triu(xy_array) + triu(xy_array, 20)';
    
    % Mengatur diagonal matriks A menjadi 0
    for i = 20:50
        xy_array(i, i) = 0;
    end
    
    disp('Adjacency Matrix (xy_array):');
    disp(xy_array);
    
    % Inisialisasi variabel-variabel awal
    status = '?';
    dist = inf(20, 50); % Menginisialisasi dist dengan infinity
    next = zeros(20, 50);
    D = inf; % Variabel untuk menyimpan jarak terpendek
    
    % Mengatur node awal (source) dan node tujuan (destination)
    s = 20; % Node awal
    d = 50; % Node tujuan
    
    status(d) = '!'; % Node tujuan diberi status '!'
    dist(d) = 0;
    
    % Inisialisasi variabel RREQ
    rreq_status = '?'; % Status RREQ
    rreq_hops = inf(20, 50); % Menginisialisasi rreq_hops dengan infinity
    rreq_id = 20; % Nomor identifikasi RREQ
    rreq_dest = 50; % Node tujuan RREQ
    rreq_src = 20; % Node sumber RREQ
    
    % Menginisialisasi pesan RREQ
    rreq_packet = struct('src', rreq_src, 'id', rreq_id, 'dest', rreq_dest);
    
    % Algoritma AODV
    while status(s) ~= '!'
        D = inf;
        current_node = -20;
    
        % Pilih node dengan jarak terpendek yang belum dikunjungi
        for i = 20:50
            if status(i) == '?' && dist(i) < D
                D = dist(i);
                current_node = i;
            end
        end
    
        if current_node == -20
            break; % Tidak ada rute yang ditemukan
        end
    
        status(current_node) = '!';
    
        % Perbarui jarak ke node-node tetangga yang belum dikunjungi
        for i = 20:50
            if status(i) == '?' && xy_array(current_node, i) > 0
                if dist(current_node) + xy_array(current_node, i) < dist(i)
                    dist(i) = dist(current_node) + xy_array(current_node, i);
                    next(i) = current_node; % Perbarui node selanjutnya dalam rute
                end
            end
        end
    end

    
    % Simulasikan pengiriman RREQ dari node sumber ke node tujuan
    disp(['Node ' num2str(rreq_src) ' sends RREQ to node ' num2str(rreq_dest)]);
    % Pada aplikasi nyata, Anda akan mengirim pesan ke jaringan nirkabel di sini.
    
    % Penerima RREQ (node tujuan) memeriksa pesan RREQ
    if rreq_dest == d
        % Jika node penerima adalah node tujuan RREQ, maka proses pesan RREQ.
        if rreq_packet.id > rreq_hops(rreq_packet.src)
            % Periksa nomor identifikasi RREQ untuk menghindari duplikasi.
            % Jika RREQ memiliki nomor identifikasi lebih besar, proses RREQ.
            rreq_hops(rreq_packet.src) = rreq_packet.id;
    
            % Kirim RREP sebagai tanggapan ke node sumber.
            % Ini juga melibatkan perhitungan dan pengiriman RREP.
            % Namun, RREP akan ditambahkan setelah RREQ selesai.
        end
    else
        % Jika node penerima bukan tujuan, meneruskan RREQ ke node tetangga yang sesuai.
        % Ini melibatkan proses pengiriman pesan RREQ ke tetangga.
        % Anda harus memiliki data koneksi atau daftar tetangga untuk ini.
        disp(['Node ' num2str(rreq_dest) ' forwards RREQ to its neighbors']);
        % Pada aplikasi nyata, Anda akan mengirim pesan ke tetangga yang sesuai.
    end
    
    current_node = 50; % Inisialisasi node saat ini dengan node tujuan (node 50)
    count = 20;
    route(count) = 50;
    
    while current_node ~= 20
        if current_node == 0 || current_node > 50
            disp('No valid route found.');
            break;
        end
        disp(['Node ' num2str(current_node) ' sends RREP message to node ' num2str(next(current_node))]);
        current_node = next(current_node);
        count = count + 20;
        route = [route, current_node];
    end
    
    if numel(route) > 0
        if count == 0
            count = 20;
        end
    
        disp(['Node ' num2str(current_node) ' sends RREP to node 20']);
        for i = count-20:20
            % Iterasi melalui rute yang ditemukan
            disp(['Sends message to node ' num2str(route(i))]);
        end
    
        % Menampilkan hasil rute
        disp('Rute yang ditemukan (dari node 20 ke node 50):');
        disp(route);
    
        % Menampilkan pesan untuk pembentukan rute
        disp('Pesan yang dikirim untuk pembentukan rute');
        
%         for i = 1:numel(route)
%             if i == 1
%                 disp(['Node ' num2str(route(i)) ' mengirim RREP ke node ' num2str(next(route(i)))]);
%             elseif i == numel(route)
%                 disp(['Node ' num2str(route(i)) ' mengirim pesan ke node 1']);
%             else
%                 next_node = next(route(i));
%                 if next_node >= 1 && next_node <= 50
%                     disp(['Node ' num2str(route(i)) ' mengirim pesan ke node ' num2str(next_node)]);
%                 else
%                     disp(['Node ' num2str(route(i)) ' mencapai node tujuan yang tidak valid.']);
%                 end
%             end
%         end
    end


    % Tentukan koordinat lokasi wormhole
    lokasi_x1 = 100; 
    lokasi_x2 = 200; 
    lokasi_y1 = 50;  
    lokasi_y2 = 60; 

    % Menambahkan elemen visualisasi untuk serangan wormhole
    x_wormhole = [lokasi_x1, lokasi_x2]; 
    y_wormhole = [lokasi_y1, lokasi_y2]; 
    plot(x_wormhole, y_wormhole, 'x', 'MarkerSize', 10, 'MarkerEdgeColor', 'black', 'LineWidth', 2);
    
    % Menambahkan label atau teks untuk menunjukkan wormhole
    text(x_wormhole(1), y_wormhole(1), 'WH 1', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
    text(x_wormhole(2), y_wormhole(2), 'WH 2', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
 
%     % Tentukan neighborhoods dari node A dan B
%     NA1 = [1, 2, 3]; 
%     NA2 = [2, 4, 5];  
%     NB1 = [3, 6, 7]; 
%     NB2 = [2, 8, 9]; 
%     
%     % Inisialisasi variabel untuk menyimpan hasil
%     result = 'belum ditentukan';
%     
%     % Cek jika N(A)1 ∩ N(B)1
%     if any(ismember(NA1, NB1))
%         result = 'Legitimate';
%     elseif any(ismember(NA1, NB2))
%         result = 'Legitimate';
%     else
%         result = 'Malicious';
%     end
%     
%     % Tampilan Hasil
%     disp(['Node A adalah ' result]);

    legend('mobil','taxi', 'RSU', 'Location', 'northwest');

    pause(0.45);

    data.Kondisi = kondisi;
    %writetable(data, filename, 'Sheet', sheet, 'WriteVariableNames', true);

    % Membuat objek Koneksi V2V dan V2I
    v2vConnection = V2VConnection(data);
    v2iConnection = V2IConnection(data);

%     % penggunaan objek v2vConnection:
%     v2vData = v2vConnection.Data; 
%     v2vRSUs = v2vConnection.Vehicles; 
%     
%     % penggunaan objek v2iConnection:
%     v2iData = v2iConnection.Data; 
%     v2iRSUs = v2iConnection.RSUs;

        
end
hold off;

