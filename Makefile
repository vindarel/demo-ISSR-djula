LISP=sbcl

# Run the app from sources.
#
# note: if we add --non-interactive as we often do, then we won't get a Lisp REPL and the web app will close right away.
run:
	rlwrap $(LISP) --load issr-test.asd --eval '(ql:quickload :issr-test)' --eval '(issr-test::main)'

