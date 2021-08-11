(in-package #:asdf-user)

(defsystem :issr-test
  :author "vindarel <vindarel@mailz.org>"
  :maintainer "vindarel <vindarel@mailz.org>"
  :license "MIT"
  :version "0.0"
  :homepage ""
  :bug-tracker ""
  :source-control (:git "")
  :description "Interactive TODO-app with ISSR without JavaScript"

  ;; build .deb (try to)
  :defsystem-depends-on ("linux-packaging")
  :class "linux-packaging:deb"
  :package-name "issr-test"

  :depends-on (:str)
  :components ((:file "issr-test")
               (:static-file "README.md"))

  :build-operation "linux-packaging:build-op"
  :build-pathname "issr-test"
  :entry-point "issr-test::main"
  )
