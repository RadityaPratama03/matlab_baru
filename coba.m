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
    xy_array = [xy_array; x(idx) y(idx)];
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

        % Menambahkan kondisi "reachable" atau "unreachable"
        kondisi = cell(size(data, 1), 1); % 
        for k = 1:size(data, 1)
            if x(k) <= 300 
                 kondisi{k} = 'reachable';
            elseif y(k) <= 300 
                 kondisi{k} = 'unreachable';
            end
        end

        % Menghitung TraceCount Reachable/Second
        traceCount = zeros(size(xy_array, 1), 1);
        reachableDuration = zeros(size(xy_array, 1), 1);
        
        for k = 1:size(xy_array, 1) 
            if k == 1
                if strcmp(kondisi{k}, 'reachable')
                    reachableDuration(k) = 1;
                else
                    reachableDuration(k) = 0;
                end
            else
                if strcmp(kondisi{k}, 'reachable')
                    reachableDuration(k) = reachableDuration(k-1) + 1;
                else
                    reachableDuration(k) = reachableDuration(k-1) - 1;
                end
            end
            traceCount(k) = k;
        end
    end
    legend('mobil','taxi', 'RSU', 'Location', 'northwest');

    % Plot untuk Duration
    subplot(5, 1, 2);
    plot(traceCount(start1:i),reachableDuration(start1:i), '-', 'Color', 'red');
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

    % Menambahkan centroid atau head cluster
    for cluster_points = 1:k
        marker = 'o';
        color = 'red';
        
        % Menghitung jarak antara centroid dengan RSU
        distance_to_rsu = sqrt((C(cluster_points, 1) - rsu_x).^2 + (C(cluster_points, 2) - rsu_y).^2);
        
        % Menentukan warna berdasarkan jarak
        if distance_to_rsu <= 30
            color = 'green'; % Ubah warna menjadi hijau jika terkoneksi RSU
        end
        
        % Plot centroid atau head cluster
        scatter3(C(cluster_points, 1), C(cluster_points, 2), C(cluster_points, 3), 200, color, 'X', 'LineWidth', 2);
        hold on;
        
        % Menghubungkan head cluster sesama cluster (V2V)
        for other_cluster = 1:k
            if other_cluster ~= cluster_points
                % Menghitung jarak antara dua head cluster
                distance_to_other = sqrt((C(cluster_points, 1) - C(other_cluster, 1))^2 + (C(cluster_points, 2) - C(other_cluster, 2))^2);
            end
        end
    end
    
    % Hapus node kendaraan yang bukan head cluster
    for i = 1:size(data_xy_angle_speed, 1)
        connected_to_rsu = false;
        for cluster_points = 1:k
            % Menghitung jarak antara node dengan centroid cluster
            distance_to_centroid = sqrt((data_xy_angle_speed(i, 1) - C(cluster_points, 1))^2 + (data_xy_angle_speed(i, 2) - C(cluster_points, 2))^2);
            if distance_to_centroid <= 30
                connected_to_rsu = true;
                break;
            end
        end
    end
    
    % Menghilangkan data yang tidak terhubung ke RSU
    data_xy_angle_speed = data_xy_angle_speed(~any(isnan(data_xy_angle_speed), 2), :);
    
    % Tampilkan legenda
    legend('RSU', 'Headcluster', 'Location', 'northwest');

    % Plot untuk Wormhole
    subplot(5, 1, 5);
    cla;
    plot(x(idx_mobil), y(idx_mobil), 'o', 'MarkerFaceColor', 'Green');
    hold on;
    plot(x(idx_taxi), y(idx_taxi), 'o', 'MarkerFaceColor', 'Red');
    hold on;
    text(rsu_x, rsu_y, 'RSU', 'HorizontalAlignment', 'left')
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
    legend('mobil','taxi', 'RSU', 'Location', 'northwest');

    pause(0.45);

    data.Kondisi = kondisi;
    %writetable(data, filename, 'Sheet', sheet, 'WriteVariableNames', true);

    % Membuat objek Koneksi V2V dan V2I
    v2vConnection = V2VConnection(data);
    v2iConnection = V2IConnection(data);

%     % Contoh penggunaan objek v2vConnection:
%     v2vData = v2vConnection.Data; 
%     v2vRSUs = v2vConnection.Vehicles; 
%     
%     % Contoh penggunaan objek v2iConnection:
%     v2iData = v2iConnection.Data; 
%     v2iRSUs = v2iConnection.RSUs;

        
end
hold off;

