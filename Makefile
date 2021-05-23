LISP=sbcl

run:
	$(LISP) --non-interactive --load issr-test.asd --eval '(ql:quickload :issr-test)' --eval '(issr-test::main)'

