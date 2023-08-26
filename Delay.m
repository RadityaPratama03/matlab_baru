filename = 'Hsimulasi.xlsx';
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

%A = 160;
%B = 30;
B5 = 40; % Bandwidth yang digunakan pada dalam satuan MHz
B6 = 80; % Bandwidth yang digunakan pada dalam satuan MHz
start1 = 11;

figure; % Membuat figure baru

subplot(4, 1, 1);
axis([-50 350 -40 120]);
title('Jalur PKU');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

subplot(4, 1, 2);
axis([10 inf 18.6 inf]);
title('Analisis Perbandingan 5G & 6G');
xlabel('Jumlah kendaraan (s)');
ylabel('decibel(dB)');
grid on;
hold on;

subplot(4, 1, 3); % Subplot untuk menghitung delay
axis([10 inf 300 inf]);
title('Delay Berdasarkan Jarak');
xlabel('Jumlah Kendaraan (s)');
ylabel('Delay (ms)');
grid on;
hold on;

subplot(4, 1, 4); % Subplot untuk menghitung throughput
%axis([10 inf 800 1200]);
axis('auto');
title('Pengaruh Throughput terhadap Jarak');
xlabel('Jumlah Kendaraan (s)');
ylabel('Throughput (kbps)');
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

for i = 1:length(Data_t)
    subplot(4, 1, 1);
    cla;
    idx = t == Data_t(i);
    xy_array = [xy_array; x(idx) y(idx)];
    distance1 = sqrt((xy_array(:, 1).^2) + (xy_array(:, 2).^2));

    % Menghitung path loss dB
    dB5 = 20*log10(distance1/3600) + 20*log10(f_5G) + K;
    dB6 = 20*log10(distance1/3600) + 20*log10(f_6G) + K;
    dB_avg5 = [dB_avg5; mean(dB5)];
    dB_avg6 = [dB_avg6; mean(dB6)];


    % Menghitung delay berdasarkan jarak
    K5 = 10.^(dB5/10); % Menentukan linier dengan menggunakan dB
    K6 = 10.^(dB6/10);
    delay5 = log10(distance1).*K5;
    delay6 = log10(distance1).*K6;
    delay_avg5 = [delay_avg5; mean(delay5)];
    delay_avg6 = [delay_avg6; mean(delay6)];

    % Menghitung throughput
    %Throughput = A *log10(distance1)-B; % Model Log-Distance dlm linier
    %Throughput_avg = [Throughput_avg; mean(Throughput)];
    %Throughput = A - B * log10(distance1); % Model Log-Distance
    Throughput5 = B5 * log2(1 + K5); % Rumus Shannon Capacity Formula
    Throughput6 = B6 * log2(1 + K6);
    Throughput_avg5 = [Throughput_avg5; mean(Throughput5)];
    Throughput_avg6 = [Throughput_avg6; mean(Throughput6)];

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
            distance2 = sqrt((x_l(k+1) - x_l(k))^2 + (y_l(k+1) - y_l(k))^2);

            % Memilih warna berdasarkan jarak
            if distance2 <= 30
                line_color = 'red'; % Warna merah untuk jarak <= 10 meter
            elseif distance2 <= 50
                line_color = 'green'; % Warna kuning untuk jarak <= 20 meter
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
    legend('mobil','taxi', 'RSU', 'Location', 'northwest');

    % Plot for subplot
    subplot(4, 1, 2);
    plot(Data_t(start1:i), dB_avg5(start1:i), '-', 'Color', 'red');
    hold on;
    plot(Data_t(start1:i), dB_avg6(start1:i), '-', 'Color', 'green');
    legend('5G','6G', 'Location', 'northwest');

    % Plot for subplot
    subplot(4, 1, 3);
    plot(Data_t(start1:i),delay_avg5(start1:i), '-', 'Color', 'blue');
    hold on;
    plot(Data_t(start1:i),delay_avg6(start1:i), '-', 'Color', 'black');
    legend('5G','6G', 'Location', 'northwest');
    
    % Plot for subplot
    subplot(4, 1, 4);
    plot(Data_t(start1:i),Throughput5(start1:i), '-', 'Color', 'blue');
    hold on;
    plot(Data_t(start1:i),Throughput6(start1:i), '-', 'Color', 'green');
    legend('5G','6G','Location', 'northwest');
    

    pause(0.45);
end
hold off;
