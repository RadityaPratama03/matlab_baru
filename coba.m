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

subplot(4, 1, 1);
axis([-50 350 -40 120]);
title('Jalur PKU');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

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
traceCount = [];
reachableDuration = [];

for i = 1:length(Data_t)
    subplot(4, 1, 1);
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
    
    % Menambahkan data sudut (angle) dan normalisasi
    data_angle = a; 
    min_angle = min(data_angle);
    max_angle = max(data_angle);
    
    % Normalisasi data sudut ke rentang yang sama dengan data x dan y
    min_range = min(x); 
    max_range = max(x); 
    
    normalized_angle = min_range + ((data_angle - min_angle) / (max_angle - min_angle)) * (max_range - min_range);
    
    % Menambahkan clustering K-Medoids menggunakan data x, y, dan sudut yang telah dinormalisasi
    data_xy_angle = [x(idx), y(idx), normalized_angle(idx)];
    k = 4; 
    [idx_medoids, C, sumd, D] = kmedoids(data_xy_angle, k, 'Distance', 'euclidean');
    
    % Menggambar hasil clustering dengan warna yang berbeda
    for cluster = 1:k
        cluster_points = data_xy_angle(idx_medoids == cluster, :);
    
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
    
        % Plot titik-titik yang termasuk dalam cluster
        scatter3(cluster_points(:, 1), cluster_points(:, 2), cluster_points(:, 3), 50, color, marker, 'filled');
        hold on;
    
        % Plot medoid cluster dengan tanda bintang
        scatter3(C(cluster, 1), C(cluster, 2), C(cluster, 3), 200, color, 'X', 'LineWidth', 2);
        hold on;
    end
  
    % Menambahkan label pada plot
    xlabel('Data x');
    ylabel('Data y');
    zlabel('Normalized Angle');
    title('Hasil Clustering K-Medoids (4 Cluster) dengan Data Sudut yang Dinormalisasi');
    
    % Menampilkan legenda
    legend('RSU', 'Cluster 1', 'Head Cluster 1', 'Cluster 2', 'Head Cluster 2', 'Cluster 3', 'Head Cluster 3', 'Cluster 4', 'Head Cluster 4', 'Location', 'northwest');
       
    pause(0.45);

    data.Kondisi = kondisi;
    %writetable(data, filename, 'Sheet', sheet, 'WriteVariableNames', true);

    % Membuat objek Koneksi V2V dan V2I
    v2vConnection = V2VConnection(data);
    v2iConnection = V2IConnection(data);
        
end
hold off;

