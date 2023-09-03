src=$(wildcard *.v)
all: CPU.out

CPU.out: $(src)
	iverilog -o CPU.out $(src)

test: CPU.out
	@vvp CPU.out > /dev/null
	@diff output.txt output_ref.txt
	@if [ $$? -eq 0 ]; then \
		echo "Success"; \
	fi

clean:
	rm -rf CPU.out
