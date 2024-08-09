function encoded_data = symbol_mapping_dbpsk_old (input_data)
  encoded_data = logical(zeros(length(input_data),1));
  encoded_data_k_minus_1 = 0;
  for k=1:length(encoded_data)
    encoded_data(k) = (xor(input_data(k),encoded_data_k_minus_1));
    encoded_data_k_minus_1 = encoded_data(k);
  endfor
  ind = find(encoded_data == 0);
  encoded_data = int16(encoded_data);
  encoded_data(ind)=-1;
  encoded_data = encoded_data*1;
endfunction
