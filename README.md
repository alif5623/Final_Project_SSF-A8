# Final_Project_SSF-A8
Fire Alarm

Rangkaian ini bertujuan untuk memberikan peringatan berupa suara dan visual melalui LED dan buzzer ketika terjadi perubahan suhu yang signifikan akibat api. 
Rangkaian terdiri dari dua arduino yang terhubung dengan I2C, arduino master terhubung ke sensor dan berfungsi untuk menerima dan mengolah data dari sensor DHT11. Arduino slave terhubung dengan aktuator yang akan mengaktifkan seluruh aktuator ketika suhu melebihi 0x30 atau 48 derajat celcius. Aktuator pada rangkaian ini adalah LED yang berfungsi sebagai pemberi peringatan berupa visual, buzzer yang berfungsi sebagai pemberi peringatan berupa audio, serta dc motor pump yang berfungsi untuk menjalankan tindakan preventif agar persebaran api dapat dihentikan sebelum semakin besar. 

