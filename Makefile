test.vvp: ALU.v test_ALU.v
		iverilog -o "test.vvp" ALU.v test_ALU.v

clean:
		rm *.vvp 