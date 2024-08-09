function states_q = my_crc(input_bits, initial_state)
  states_q = initial_state; %BE AWARE! example: [0 1 1 0 1 0 0] -> [MSB ... LSB] that means... [state7 ... state1]
  states_d = initial_state;
  states_d(16) = xor(states_q(1),0);
  states_d(11) = xor(states_d(16),states_q(12));
  states_d(4) = xor(states_d(16),states_q(5));
  for n=1:length(input_bits)
    states_d(16) = xor(states_q(1),input_bits(n));
    states_d(15) = states_q(16);
    states_d(14) = states_q(15);
    states_d(13) = states_q(14);
    states_d(12) = states_q(13);
    states_d(11) = xor(states_d(16),states_q(12));
    states_d(10) = states_q(11);
    states_d(9) = states_q(10);
    states_d(8) = states_q(9);
    states_d(7) = states_q(8);
    states_d(6) = states_q(7);
    states_d(5) = states_q(6);
    states_d(4) = xor(states_d(16),states_q(5));
    states_d(3) = states_q(4);
    states_d(2) = states_q(3);
    states_d(1) = states_q(2);
    states_q = states_d;
  end
  states_q = not(states_q);
endfunction
