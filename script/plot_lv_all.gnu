set terminal pngcairo size 800,600 enhanced font 'Arial,12'
set output 'graphs/lv_all_minmax.png'

set title 'Top 10 LV Stations with Highest and Lowest Consumption'
set xlabel 'LV Station ID'
set ylabel 'Energy Consumption (kWh)'
set grid
set style data histogram
set style fill solid
set boxwidth 0.5
set xtic rotate by -45
set datafile separator ":"  # Adjust separator if needed
plot 'tmp/lv_all_minmax.csv' using 2:xtic(1) title 'Consumption' lc rgb '#FF5733' 