LISP=sbcl

# Run the app from sources.
#
# note: if we add --non-interactive as we often do, then we won't get a Lisp REPL and the web app will close right away.
run:
	rlwrap $(LISP) --load issr-test.asd --eval '(ql:quickload :issr-test)' --eval '(issr-test::main)'

# experimental: build a .deb with linux-packaging.
build-package:
	$(LISP) --non-interactive \
		--load issr-test.asd \
		--eval '(ql:quickload :issr-test)' \
		--eval '(load "~/common-lisp/asdf/tools/load-asdf.lisp")' \
		--eval '(setf *debugger-hook* (lambda (c h) (declare (ignore h)) (format t "~A~%" c) (sb-ext:quit :unix-status -1)))' \
		--eval '(asdf:make :issr-test)' \
		--eval '(uiop:format! t "Makefile finished.~&")'
