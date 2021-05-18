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
  :depends-on (:hunchenissr
               :log4cl
               :markup
               :djula
               :str)
  :components ((:file "issr-test")
               (:static-file "README.md"))


  :in-order-to ((test-op (test-op :str.test))))
