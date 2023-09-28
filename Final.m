filename = 'Hsimulasicut.xlsx';
sheet = 'Sheet2';
data = readtable(filename, 'Sheet', sheet);

t = data.time;
x = data.x;
y = data.y;
l = data.lane;
p = data.type;

f_5G = 5.9; % Standar VANET 802.11p (Ghz)
f_6G = 6; % Perkiraan frekuensi yang digunakan pada 6G

K = 30; % Konstanta berbeda setiap lingkungan

% Sistem 5G Nilai kisaran
A5 = 498; % Satuan Kbps
B5 = 30;

% Sistem 6G Nilai kisaran
A6 = 500; % Satuan Kbps 
B6 = 30;

%B5 = 40; % Bandwidth yang digunakan pada dalam satuan MHz
%B6 = 80; % Bandwidth yang digunakan pada dalam satuan MHz
start1 = 1;

figure; % Membuat figure baru

subplot(4, 1, 1);
axis([-50 350 -40 120]);
title('Jalur PKU');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

% subplot(7, 1, 2);
% axis([10 inf 18.671 inf]);
% title('Analisis Perbandingan 5G & 6G');
% xlabel('Jumlah kendaraan');
% ylabel('decibel (dB)');
% grid on;
% hold on;
% 
% subplot(7, 1, 3); % Subplot untuk menghitung delay
% %axis('auto');
% axis([10 inf 155.283 inf]);
% title('Delay Berdasarkan Jarak');
% xlabel('Jumlah Kendaraan');
% ylabel('Delay (ms)');
% grid on;
% hold on;
% 
% subplot(5, 1, 2); % Subplot untuk menghitung throughput
% %axis([10 inf 434 134]);
% axis('auto');
% title('Pengaruh Throughput');
% xlabel('Jumlah Kendaraan');
% ylabel('Throughput (Kbps)');
% grid on;
% hold on;

subplot(4, 1, 2); % Subplot untuk menghitung reachable
%axis('auto');
axis([10 inf 0 inf]);
title('TraceCount Reachable');
xlabel('Jumlah Kendaraan');
ylabel('Duration (s)');
grid on;
hold on;

subplot(4, 1, 3);
axis([-50 350 -40 120]);
title('Jalur PKU Reachable dan Unreachable');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

subplot(4, 1, 4);
axis([-50 350 -40 120]);
title('Jalur PKU Cluster');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

Data_t = unique(t);
Data_p = unique(p);
Data_l = unique(l);
xy_array = [];
dB_avg6 = [];
dB_avg5 =[];
delay_avg5 = [];
delay_avg6 = [];
Throughput_avg5 = [];
Throughput_avg6 = [];
Throughput_avg = [];
delay_avg =[];
traceCount = [];
reachableDuration = [];

for i = 1:length(Data_t)
    subplot(4, 1, 1);
    cla;
    idx = t == Data_t(i);
    xy_array = [xy_array; x(idx) y(idx)];
    distance1 = sqrt((xy_array(:, 1).^2) + (xy_array(:, 2).^2));

%     % Menghitung path loss dB
%     dB5 = 20*log10(distance1/3600) + 20*log10(f_5G) + K;
%     dB6 = 20*log10(distance1/3600) + 20*log10(f_6G) + K;
%     dB_avg5 = [dB_avg5; mean(dB5)];
%     dB_avg6 = [dB_avg6; mean(dB6)];
% 
% 
%     % Menghitung delay berdasarkan jarak (delay itu kendaraan semakin banyak maka delay semakin besar)
%     delay5 = 4 + 10 * 3 * log(distance1); % Model log-distance path loss
%     delay6 = 2 + 10 * 3 * log(distance1);
%     delay_avg5 = [delay_avg5; mean(delay5)];
%     delay_avg6 = [delay_avg6; mean(delay6)];

    %K5 = 10.^(dB5/10); % Menentukan linier dengan menggunakan dB
    %K6 = 10.^(dB6/10);
    %delay5 = log10(distance1).*K5;
    %delay6 = log10(distance1).*K6;
    %delay_avg5 = [delay_avg5; mean(delay5)];
    %delay_avg6 = [delay_avg6; mean(delay6)];

%     % Menghitung throughput
%     Throughput5 = A5 - B5 * log10(distance1); % Model Log-Distance
%     Throughput_avg5 = [Throughput_avg5; mean(Throughput5)];
% 
%     Throughput6 = A6 - B6 * log10(distance1); % Model Log-Distance
%     Throughput_avg6 = [Throughput_avg6; mean(Throughput6)];


    %Throughput = A *log10(distance1)-B; % Model Log-Distance dlm linier
    %Throughput_avg = [Throughput_avg; mean(Throughput)];

    %Throughput = A - B * log10(distance1); % Model Log-Distance
    %Throughput_avg = [Throughput_avg; mean(Throughput)];

    %Throughput5 = B5 * log2(1 + K5); % Rumus Shannon Capacity Formula
    %Throughput6 = B6 * log2(1 + K6);
    %Throughput_avg5 = [Throughput_avg5; mean(Throughput5)];
    %Throughput_avg6 = [Throughput_avg6; mean(Throughput6)];

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
            %else
                 %kondisi{k} = '';
            end
        end

        % Menghitung TraceCount Reachable/Second
        traceCount = zeros(size(xy_array, 1), 1);
        reachableDuration = zeros(size(xy_array, 1), 1);
        
        for k = 1:size(xy_array, 1) % ubah data x, y
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

%     % Plot untuk dB
%     subplot(7, 1, 2);
%     plot(Data_t(start1:i), dB_avg5(start1:i), '-', 'Color', 'red');
%     hold on;
%     plot(Data_t(start1:i), dB_avg6(start1:i), '-', 'Color', 'green');
%     legend('5G','6G', 'Location', 'northwest');
% 
%     % Plot untuk Delay
%     subplot(7, 1, 3);
%     plot(Data_t(start1:i),delay_avg5(start1:i), '-', 'Color', 'red');
%     hold on;
%     plot(Data_t(start1:i),delay_avg6(start1:i), '-', 'Color', 'green');
%     legend('5G','6G', 'Location', 'northwest');
%     
%     % Plot untuk Throughput
%     subplot(5, 1, 2);
%     plot(Data_t(start1:i),Throughput_avg5(start1:i), '-', 'Color', 'red');
%     hold on;
%     plot(Data_t(start1:i),Throughput_avg6(start1:i), '-', 'Color', 'green');
%     legend('5G','6G','Location', 'northwest');

    % Plot untuk Duration
    subplot(4, 1, 2);
    plot(traceCount(start1:i),reachableDuration(start1:i), '-', 'Color', 'red');
    hold on;
    legend('mobil&taxi', 'Location', 'northwest');
   
    % Plot untuk Reachable dan Unreachable
    subplot(4, 1, 3);
    cla;
    plot(x(idx_mobil), y(idx_mobil), 'o', 'MarkerFaceColor', 'Green');
    hold on;
    plot(x(idx_taxi), y(idx_taxi), 'o', 'MarkerFaceColor', 'Red');
    hold on;
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

        % Menghitung jarak antara titik dengan RSU dan overwrite data
        distance_to_rsu = sqrt((x - rsu_x).^2 + (y - rsu_y).^2);
        data.Distance_to_RSU = distance_to_rsu;

        % Menggambar garis yang menghubungkan titik dengan RSU
        for k = 1:length(x_l(idx_rsu))
            line1 = plot([x_l(idx_rsu(k)), rsu_x], [y_l(idx_rsu(k)), rsu_y], '--', 'Color', 'cyan');
        end
        
        % Memberikan warna pada mobil & taxi ketika jarak >= 300
        for k = 1:size(x_l)
            Xi = x_l(k);
            Yi = y_l(k);
            id_i = id_l(k); % Id kendaraan
            type_i = type_l{k}; % Type kendaraan
            if Xi <= 300 && sqrt((Xi - rsu_x).^2 + (Yi - rsu_y).^2) <= 30
                node_color = 'Green';
            elseif Yi <= 300 
                node_color = 'Red';
            end
            plot(Xi, Yi, 'o', 'MarkerFaceColor', node_color);
            %text(Xi, Yi, [' ' id_i ,  type_i], 'Color', 'black', 'FontSize', 8);
            %text(Xi, Yi, [type_i], 'Color', 'black', 'FontSize', 8);
        end
    end
    legend('reachable','unreachable', 'RSU', 'Location', 'northwest');
    %legend('mobil','taxi', 'RSU', 'Location', 'northwest');
    
    % Plot untuk Clustering
    subplot(4, 1, 4);
    cla;
    hold on;

    % Data x dan y dalam matriks "data"
    x = data.x;
    y = data.y;

    % Jumlah cluster yang diinginkan
    numClusters = 4; 
    
    % Menambahkan clustering dua arah 
    num_clusters_x = 4; 
    num_clusters_y = 4; 
    
    % Melakukan K-Medoids clustering untuk dimensi x dan y
    x_data = [x(idx_mobil); x(idx_taxi)];
    y_data = [y(idx_mobil); y(idx_taxi)];
    data_points = [x_data, y_data];
    
    % Melakukan K-Medoids clustering
    [idx_clusters, C] = kmedoids(data_points, numClusters);
    
    % Menentukan cluster untuk setiap data point
    clusters_x = zeros(size(data_points, 1), 1);
    clusters_y = zeros(size(data_points, 1), 1);
    for i = 1:numClusters
        cluster_idx = idx_clusters == i;
        clusters_x(cluster_idx) = i;
        clusters_y(cluster_idx) = i;
    end
    
    colors = ['b', 'g', 'r', 'c'];
    
    for i = 1:numClusters
        cluster_idx = idx_clusters == i;
        plot(x_data(cluster_idx), y_data(cluster_idx), 'o', 'MarkerFaceColor', colors(i));
    end
    
    % Menambahkan legend untuk cluster
    legend_strings = cell(numClusters, 1);
    for i = 1:numClusters
        legend_strings{i} = sprintf('Cluster %d', i);
    end
    
    % Menentukan titik referensi sebagai "head"
    x_ref = 120;
    y_ref = 50;
    
    % Menghitung jarak antara titik referensi dan medoid dari masing-masing cluster
    distances_to_reference = zeros(numClusters, 1);
    for i = 1:numClusters
        cluster_points = data_points(idx_clusters == i, :);
        medoid_idx = knnsearch(cluster_points, C(i, :));
        medoid = cluster_points(medoid_idx, :);
        distances_to_reference(i) = sqrt((medoid(1) - x_ref)^2 + (medoid(2) - y_ref)^2);
    end
    
    % Menentukan head cluster (cluster dengan medoid terdekat)
    [~, head_cluster_id] = min(distances_to_reference);
    
    % Menampilkan tentang head cluster
    fprintf('Head Cluster ID: %d\n', head_cluster_id);
    fprintf('Head Cluster Medoid: (%.2f, %.2f)\n', C(head_cluster_id, 1), C(head_cluster_id, 2));

    % Menambahkan kolom cluster kepala ke dalam matriks data
    data_with_clusters = [x_data, y_data, clusters_x, clusters_y, head_cluster_id * ones(size(x_data))];
    
    legend(legend_strings, 'Location', 'northwest');
    
    % Plot RSU
    plot(rsu_x, rsu_y, 'h', 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    text(rsu_x, rsu_y, ' RSU ', 'HorizontalAlignment', 'left')
    
    xlabel('Data x');
    ylabel('Data y');

    % Menampilkan label untuk head cluster
    head_cluster_points = data_points(idx_clusters == head_cluster_id, :);
    %text(head_cluster_points(:, 1), head_cluster_points(:, 2), 'HC', 'Color', 'k', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
 
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
    
        % Menghitung jarak antara titik dengan RSU dan overwrite data
        distance_to_rsu = sqrt((x - rsu_x).^2 + (y - rsu_y).^2);
        data.Distance_to_RSU = distance_to_rsu;
    
        % Menggambar garis yang menghubungkan titik dengan RSU
        for k = 1:length(x_l(idx_rsu))
            line1 = plot([x_l(idx_rsu(k)), rsu_x], [y_l(idx_rsu(k)), rsu_y], '--', 'Color', 'cyan');
        end
    end
    
    % Menambahkan legend untuk cluster
    legend_str = cell(1, numClusters);
    for i = 1:numClusters
        legend_str{i} = ['Cluster ' num2str(i)];
    end
    legend([legend_str, 'RSU'], 'Location', 'northwest');

    pause(0.45);

    data.Kondisi = kondisi;
    %outputData = table2cell(data);
    %outputData = {'time','id', 'x', 'y', 'lane', 'type','speed','pos','lane','slope', 'kondisi'};
    %outputFile = 'Hsimulasi_with_kondisi.xlsx';
    %xlswrite(outputFile, outputData, sheet);
    %outputFilename = 'Hsimulasi_with_kondisi.xlsx';
    writetable(data, filename, 'Sheet', sheet, 'WriteVariableNames', true);

    % Membuat objek Koneksi V2V dan V2I
    v2vConnection = V2VConnection(data);
    v2iConnection = V2IConnection(data);
        
end
hold off;
