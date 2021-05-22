
#+(or)
(ql:quickload '("hunchenissr" "markup" "log4cl"))

;; elisp side:
;; (add-to-list 'load-path "~/quicklisp/dists/quicklisp/software/markup-20201220-git/")
;; (require 'lisp-markup)
;;
;; It's possible to use C-c C-p to eval and print the generated HTML in a buffer. With djula:render-template* or markup.

(defpackage :issr-test
  (:use :cl
        :markup)
  (:import-from #:hunchenissr
                define-easy-handler
                *id*
                *ws-port*
                start
                stop))

(in-package #:issr-test)

(djula:add-template-directory (asdf:system-relative-pathname "issr-test" "templates/"))
(defparameter +base.html+ (djula:compile-template* "base.html"))
(defparameter +products.html+ (djula:compile-template* "products.html"))

(defparameter *server* nil
  "Hunchentoot acceptor.")

(defparameter *products* (list))

(defun start-app ()
  (setf *server*
        (start (make-instance 'hunchentoot:easy-acceptor
                              :port 8080
                              :document-root "resources/")
               :ws-port 4433)))

;;
;; models.lisp
;;
;; Imagine it's our DB interface.
;;
(defclass product ()
  ((id :initform (string (gensym "ID-"))
       :accessor product-id)
   (title :initform ""
          :initarg :title
          :accessor title
          :type string)
   (done :initform nil
         :initarg :done
         :accessor done
         :type boolean)
   (weight :initform (1+ (random 4))
           ;; :initarg :weight
           :accessor weight
           :type integer
           :documentation "We give a weight to the item, only to print more elements on the page.")))

(defmethod print-object ((obj product) stream)
  (print-unreadable-object (obj stream :type t)
    (format stream "~a" (slot-value obj 'title))))

(defun make-product (title)
  (make-instance 'product :title title))

(defun find-product-by-id (id)
  (find id *products* :test #'equal :key #'product-id))

(defun delete-product-from-id (id)
  (delete id *products* :test #'equal :key #'product-id))

(defun create-products ()
  (loop for title in '("foo" "bar" "baz")
     collect (make-product title)))

;; Start with data.
(setf *products* (create-products))

;;
;; end of the models interface.
;;

;;
;; views / route
;;
;; We have one route: localhost:8080/products
;;
(define-easy-handler (products :uri "/products")
    ;; Actions:
    (add-new-task
     new-task
     check
     delete-product)
  (let ((add-new-product-p (and add-new-task
                                new-task
                                (string= add-new-task "add")
                                (not (str:blankp new-task))))
        new-product)
    (log:info add-new-task new-task add-new-product-p (hunchentoot:get-parameters*))

    ;; Create a new product?
    (when add-new-product-p
      (setf new-product (make-product new-task))
      (setf *products* (append *products*
                               (list new-product))))

    ;; Toggle the "done" state?
    (when (str:non-blank-string-p check)
      (let* ((product (find-product-by-id check)))
        (print (setf (done product)
                     (not (done product))))))

    ;; Delete item.
    (when (str:non-blank-string-p delete-product)
      (log:info delete-product)
      (setf *products* (delete-product-from-id delete-product)))

    ;; (render-markup-template *products* :add-new-product-p add-new-product-p)
    (djula:render-template* +products.html+ nil
                            :issr-id *id*
                            :ws-port *ws-port*
                            :products *products*
                            :products-weight (loop for item in *products*
                                                sum (weight item))
                            :todos (loop for item in *products*
                                              unless (done item)
                                              collect item)
                            :add-new-task add-new-task)))

;;
;; and that's it.
;;
