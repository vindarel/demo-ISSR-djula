
#+(or)
(ql:quickload '("hunchenissr" "markup" "log4cl"))

;; elisp side:
;; (add-to-list 'load-path "~/quicklisp/dists/quicklisp/software/markup-20201220-git/")
;; (require 'lisp-markup)

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

(markup:enable-reader)

(djula:add-template-directory (asdf:system-relative-pathname "issr-test" "templates/"))
(defparameter +base.html+ (djula:compile-template* "base.html"))
(defparameter +products.html+ (djula:compile-template* "products.html"))

(defparameter *server* nil
  "Hunchentoot acceptor.")

(defun start-app ()
  (setf *server*
        (start (make-instance 'hunchentoot:easy-acceptor
                              :port 8080
                              :document-root "resources/")
               :ws-port 4433)))

(defparameter *products* (list))

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
         :type boolean)))

(defmethod print-object ((obj product) stream)
  (print-unreadable-object (obj stream :type t)
    (format stream "~a" (slot-value obj 'title))))

(defun make-product (title)
  (make-instance 'product :title title))

(defun find-product-by-id (id)
  (find id *products* :test #'equal :key #'product-id))

(defun create-products ()
  (loop for title in '("foo" "bar" "baz")
     collect (make-product title)))

(setf *products* (create-products))

(markup:deftag base-template (children &key title)
  ;; naming it simply "base" fails ?!
  <html>
    <head>
     <title>,(progn title)</title>
     <script src="/issr.js"></script>
     <script noupdate="t">
     ,(format nil "setup(~a,~a)" *id* *ws-port*)
     </script>
    </head>
    <body>
      ,@(progn children)
    </body>
  </html>)

#+(or)
;; use C-c C-p to eval and print the generated HTML in a buffer.
(markup:write-html
     <base-template title="Hello" >
        <h1>hello world!</h1>
     </base-template>)

(defparameter todos (list))

(defun render-markup-template (products &key add-new-product-p)
  (write-html
     <base-template title="Hello Products | ISSR" >
         <h1>To Do List</h1>
         <ul>
           ,@(loop for todo in products
                   for index from 0 below (length products)
                   collect
                   <li>
                  ,(progn (title todo))
                   </li>)
         </ul>
         <!-- The value attribute is to remove the content when
              a new task was just added. The update attribute is
              to ensure that the value of empty string is updated
              on the client. -->
         <input name="new-task"
                value=(when add-new-product-p
                        "")
                update=add-new-product-p
                placeholder="Product name"
                onkeydown="if (event.keyCode == 13)
                             rr({action:'add-new-task',
                                 value:'add'})"/>
         <button action="add-new-task"
                 value="add"
                 onclick="rr(this)">
           Add
         </button>
         </base-template>))

(define-easy-handler (products :uri "/products")
    ;; Actions:
    (add-new-task
     new-task
     check)
  (let ((add-new-product-p (and add-new-task
                                new-task
                                (string= add-new-task "add")
                                (not (str:blankp new-task))))
        new-product)
    (log:info add-new-task new-task add-new-product-p
              (hunchentoot:get-parameters*)
              (hunchentoot:post-parameters*))

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

    ;; (render-markup-template *products* :add-new-product-p add-new-product-p)
    (djula:render-template* +products.html+ nil
                            :issr-id *id*
                            :ws-port *ws-port*
                            :products *products*
                            :add-new-task add-new-task)

    ))
