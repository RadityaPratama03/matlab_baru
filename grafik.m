filename = 'Hsimulasi.xlsx';
sheet = 'Sheet2';
data = readtable(filename, 'Sheet', sheet);

t = data.time;
x = data.x;
y = data.y;
l = data.lane;
p = data.type;
f = 5.9; % Standar VANET 802.11p
K = 30;
n = 4;

figure; % Membuat figure baru

subplot(2, 1, 1);
axis([-50 350 -40 120]);
title('Jalur PKU');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

subplot(2, 1, 2);
axis('auto');
title('Analisis Perbandingan');
xlabel('Jumlah kendaraan per detik');
ylabel('dB');
grid on;
hold on;

Data_t = unique(t);
Data_p = unique(p);
Data_l = unique(l);
distance = [];
xy_array = [];
dB = [];
dB_avg = [];

for i = 1:length(Data_t)
    subplot(2, 1, 1);
    cla;
    idx = t == Data_t(i);
    xy_array = [xy_array; x(idx) y(idx)];
    distance_array = sqrt((xy_array(:, 1).^2) + (xy_array(:, 2).^2));
    %dB = 20*log10(distance_array/3600) + 20*log10(f) + K;
    %dB = 20*log(distance_array/3600) + 20*log(f) + K;
    %dB = 10 * n * log10(distance_array/3600) + 20 * log10(f) + K;

    % Memisahkan data berdasarkan jenis kendaraan
    idx_mobil = idx & strcmp(p, 'mobil');
    idx_taxi = idx & strcmp(p, 'taxi');

    % Plot titik koordinat mobil dengan warna hijau
    plot(x(idx_mobil), y(idx_mobil), 'o', 'MarkerFaceColor', 'green');
    hold on;

    % Plot titik koordinat taksi dengan warna merah
    plot(x(idx_taxi), y(idx_taxi), 'o', 'MarkerFaceColor', 'red');
    hold on;

    % Plot titik koordinat RSU dengan warna biru
    rsu_x = 119.797421731123;
    rsu_y = 50.2803738317757;
    text(rsu_x, rsu_y, 'RSU', 'HorizontalAlignment', 'left')
    plot(rsu_x, rsu_y, 'o', 'MarkerFaceColor', 'blue');
    hold on;

    % Menghubungkan dua titik koordinat dengan garis berdasarkan nilai unik pada Data_l
    for j = 1:length(Data_l)
        idx_l = idx & strcmp(l, Data_l(j));
        x_l = x(idx_l);
        y_l = y(idx_l);

        % Menggambar garis yang menghubungkan titik terdekat
        for k = 1:length(x_l)-1
            % Menghitung jarak antara dua titik
            distance = sqrt((x_l(k+1) - x_l(k))^2 + (y_l(k+1) - y_l(k))^2);

            % Memilih warna berdasarkan jarak
            if distance <= 30
                line_color = 'red'; % Warna merah untuk jarak <= 10 meter
            elseif distance <= 50
                line_color = 'yellow'; % Warna kuning untuk jarak <= 20 meter
            end

            % Menggambar garis dengan warna yang sesuai
            line1 = plot([x_l(k), x_l(k+1)], [y_l(k), y_l(k+1)], '--', 'Color', line_color);
        end

        % Menghitung jarak antara titik dengan RSU
        distance_to_rsu = sqrt((x_l - rsu_x).^2 + (y_l - rsu_y).^2);
        idx_rsu = distance_to_rsu <= 50;

        % Menggambar garis yang menghubungkan titik dengan RSU
        for k = 1:length(x_l(idx_rsu))
            line1 = plot([x_l(idx_rsu(k)), rsu_x], [y_l(idx_rsu(k)), rsu_y], '--', 'Color', 'blue');
        end
    end
    
    % Plot for subplot 2,1,2
    subplot(2, 1, 2);
    dB_avg = [dB_avg; mean(dB)];

    % Plot for rata-rata dB
    plot(Data_t(1:i),dB_avg, 'o-', 'Color', 'blue');

    pause(0.45);
end
hold off;
