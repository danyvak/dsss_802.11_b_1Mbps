function signal = barker_code_spread (input_data)
  barker_seq = [1 -1 1 1 -1 1 1 1 -1 -1 -1];
  barker_seq_upsampled = int16(round(resample(barker_seq,20,11)*128));
  signal = round(kron(input_data.',barker_seq_upsampled));
endfunction
