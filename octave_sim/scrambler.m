function output_bits = scrambler(input_bits, initial_state)
  states = initial_state;
  for n=1:length(input_bits)
##    if n==144
##      keyboard;
##    endif
    feedback = xor(states(4),states(7));
    output_bits(n) = xor(input_bits(n),feedback);
    states = circshift(states',1)';
    states(1)= output_bits(n);
  end
endfunction
