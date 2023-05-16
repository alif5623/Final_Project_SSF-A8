# Final_Project_SSF-A8
Fire Alarm

i. Introduction to the problem and the solution
Kebakaran adalah salah satu bencana yang sering terjadi di dunia. Kebakaran dapat disebabkan oleh kecerobohan manusia ataupun faktor alam. Persentase kebakaran yang disebabkan oleh kecerobohan manusia tidaklah kecil. Oleh karena itu dengan rangkaian fire alarm ini bertujuan untuk memberikan peringatan pada orang di sekitar ketika terdapat potensi kebakaran dan memberikan tindakan preventif seperti upaya pemadaman untuk mencegah persebaran api. 

ii. Hardware design and implementation details
Pada rangkaian kali ini, kami menggunakan Arduino Uno yang berfungsi sebagai microcontroller yang akan mengontrol semua tindakan hardware. Selain itu, terdapat sensor DHT11 yang berfungsi untuk mendeteksi keberadaan api berdasarkan suhu ruangan. Lalu, ada beberapa aktuator yang bertujuan untuk melakukan tindakan preventif dan memberi peringatan seperti LED yang akan memberikan peringatan secara visual, buzzer yang akan memberikan peringatan secara audio, dan dc water pump yang akan memompa air untuk memadamkan api sebelum menyebar semakin besar.  

iii. Software implementation details
Pada rangkaian kali ini, kami menggunakan bahasa assembly untuk mengontrol microcontroller Atmega328P pada rangkaian. Rangkaian ini menerapkan konsep arduino master-slave menggunakan I2C di mana perangkat master diprogram untuk membaca suhu ruangan menggunakan sensor DHT11 dan perangkat slave diprogram untuk menjalankan aktuator ketika kondisi yang menunjukkan potensi kebakaran akan terjadi.  

iv. Test results and performance evaluation
Hasil pengujian akhir menunjukkan bahwa rangkaian telah berhasil menyelesaikan permasalahan utama, yaitu pencegahan kebakaran meskipun masih dalam skala yang sangat sederhana. Pengiriman data sensor dari master ke slave telah berhasil ditandai dengan output pada serial monitor arduino slave yang menunjukkan hasil pembacaan dari arduino master. Selain itu, ketiga aktuator juga telah berhasil menyala dan melakukan tugasnya ketika kondisi yang dianggap berpotensi kebakaran telah terpenuhi. 

v. Conclusion and future work
Rangkaian telah berhasil memenuhi tujuannya yaitu memadamkan api dan mencegah terjadinya kebakaran. Akan tetapi, rangkaian ini masih memiliki banyak ruang untuk melakukan perkembangan seperti pergantian sensor yang digunakan agar dapat mendeteksi api dengan lebih cepat. Selain itu, rangkaian ini hanya dapat menyelesaikan permasalahan pada skala yang kecil, untuk menyelesaikan permasalahan dalam skala yang cukup besar dan sering terjadi pada kondisi nyata, alat pemadam perlu ditingkatkan dengan pemompa air yang lebih kuat sehingga dapat mengalirkan air dalam volume yang lebih besar untuk memadamkan api yang kemungkinan juga akan lebih besar pada kondisi yang sebenarnya. 


