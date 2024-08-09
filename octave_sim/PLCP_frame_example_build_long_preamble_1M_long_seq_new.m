clear all;
pkg load signal;
padding_bit = 0;
sync= logical(ones(1,128));
SFD = fliplr(logical([1 1 1 1 0 0 1 1 1 0 1 0 0 0 0 0]));
signal_field = logical([0 1 0 1 0 0 0 0]);
service = logical([0 0 0 0 0 0 0 0]);
%ram=cell(13);
ram{1}  = "FBCED126701AB234";
ram{2}  = "0123456789ABCDEF";
ram{3}  = "FEDCBA9876543210";
ram{4}  = "345AF8901BEC3567";
ram{5}  = "1212121212121212";
ram{6}  = "3434343434343434";
ram{7}  = "0123456789ABCDEF";
ram{8}  = "895034028AB8EF88";
ram{9}  = "0987654321FEBCDA";
ram{10} = "1234512345123451";
ram{11} = "6786786786786786";
ram{12} = "FAB12345BADCAFE1";
ram{13} = "FAB12345BADCAFE1";

ind = 1;
payload = uint8(zeros(1,length(ram)*8));
for k=1:length(ram)
  for m=1:8
    payload(ind) = hex2num(ram{k}((2*m-1):(2*m)),'uint8');
    ind = ind + 1;
  end
end
%payload = uint8(unicode2native('FBCED126701AB234','ascii')); %transfers an ascii to byte
PPDU_length_str = fliplr(dec2bin((length(payload)+4)*8,8));
PPDU_length = logical(zeros(1,16));
ind =  find(PPDU_length_str == '1');
PPDU_length(ind)= logical(1);
PPDU = byte_to_logical ( payload);
crc_fields = [signal_field service PPDU_length];
data_crc = my_crc(crc_fields,logical(ones(16,1)))';
crc = crc32(payload);
crc_string = fliplr(dec2bin(crc));
crc_array = logical(zeros(1,32));
ind = find(crc_string == '1');
crc_array (ind) = logical(1);
PPDU = [PPDU crc_array];
PLPC = [sync  SFD signal_field service PPDU_length data_crc PPDU];
PLPC_scrambled = scrambler(PLPC,[1 1 0 1 1 0 0]);%should [1101100] left bit is Z1s
PLPC_dbpsk = symbol_mapping_dbpsk_old ([ PLPC_scrambled]);
PLPC_barker_modulated = barker_code_spread (PLPC_dbpsk);
PLPC_barker_modulated = [rand(1,1000) PLPC_barker_modulated rand(1,1000)];
barker_seq = [1 -1 1 1 -1 1 1 1 -1 -1 -1];
barker_seq_upsampled = int16(round(resample(barker_seq,20,11)*128));
matched_filter_out_real = fftfilt (fliplr(barker_seq_upsampled),real(PLPC_barker_modulated));
figure;plot(matched_filter_out_real);
channel_filter = [0.58 1 0.61 0.47 0.7 0.173 0.08];
%channel_filter = [1 0.1 0.8 0.1 0.173 0.08];
PLPC_barker_modulated = filter(channel_filter,1,PLPC_barker_modulated) + randn(1,length(PLPC_barker_modulated))*10;
PLPC_barker_modulated_q = int16(round(PLPC_barker_modulated));
%PLPC_barker_modulated_q = shift(PLPC_barker_modulated_q,15);
figure;plot(PLPC_barker_modulated);
my_signal = (PLPC_barker_modulated + 1i*PLPC_barker_modulated)/512;
fid=fopen('data_file_iq_long.txt','w');
for k=1:length(PLPC_barker_modulated_q)
  fprintf(fid,"%d %d\n",PLPC_barker_modulated_q(k),0);
end
fclose(fid);

