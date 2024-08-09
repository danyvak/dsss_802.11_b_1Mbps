function bin_result = byte_to_logical (my_data_byte)
 temp_data_str = dec2bin(my_data_byte,8);
 n=1;
 bin_result = logical(zeros(1,size(temp_data_str,1)*8));
 for k=1:length(my_data_byte)
   for m=8:-1:1
    bin_result(n) = logical(str2num(temp_data_str (k,m)));
    n=n+1;
   endfor
 endfor
endfunction
