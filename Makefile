default:
	dune build @install

clean:
	dune clean

install:
	dune install

uninstall:
	dune uninstall

example:
	dune build examples/vgg16_example.exe

.PHONY:
	default clean install uninstall example