clear; clc;

filename = 'Hsimulasi.xlsx';
sheet = 'Sheet2';
data = readtable(filename, 'Sheet', sheet);

t = data.time;
x = data.x;
y = data.y;
l = data.lane;
p = data.type;

axis([-50 350 -40 120]);
title('Jalur PKU');
xlabel('Data x');
ylabel('Data y');
grid on;
hold on;

Data_t = unique(t);
Data_p = unique(p);
Data_l = unique(l);
distance = [];
xy_array = [];

for i= 1:length(Data_t)
    cla;
    idx = t == Data_t(i);
    xy_array = [x(idx) y(idx)];
    distance = sqrt((xy_array(:, 1).^2) + (xy_array(:, 2).^2));

    % Memisahkan data berdasarkan jenis kendaraan
    idx_mobil = idx & strcmp(p, 'mobil');
    idx_taxi = idx & strcmp(p, 'taxi');
    
    % Plot titik koordinat mobil dengan warna hijau
    plot(x(idx_mobil), y(idx_mobil), 'o', 'MarkerFaceColor', 'green');
    hold on;
    
    % Plot titik koordinat taksi dengan warna merah
    plot(x(idx_taxi), y(idx_taxi), 'o', 'MarkerFaceColor', 'red');

    % Menghubungkan dua titik koordinat dengan garis berdasarkan nilai unik pada Data_l
    for j = 1:length(Data_l)
        idx_l = idx & strcmp(l, Data_l(j));
        x_l = x(idx_l);
        y_l = y(idx_l);
        plot(x_l, y_l, 'Color', rand(1,3));
    end
    
    pause(0.45);
end
hold on;