
#+(or)
(ql:quickload '("hunchenissr" "log4cl"))

;; It's possible to use C-c C-p to eval and print the generated HTML in a buffer. With djula:render-template* or markup.

(defpackage :issr-test
  (:use :cl)
  ;; (:import-from #:hunchenissr
  ;;               define-easy-handler
  ;;               *id*
  ;;               *ws-port*
  ;;               start
  ;;               stop)
  (:export :main))

(in-package #:issr-test)

;; (djula:add-template-directory (asdf:system-relative-pathname "issr-test" "templates/"))
;; (defparameter +base.html+ (djula:compile-template* "base.html"))
;; (defparameter +products.html+ (djula:compile-template* "products.html"))
;; (defparameter +searchresults.html+ (djula:compile-template* "searchresults.html"))

;; (defparameter *server* nil
;;   "Hunchentoot acceptor.")

;; (defparameter *products* (list))

;; (defun start-app (&key (port 8080) (ws-port 4433))
;;   (setf *server*
;;         (start (make-instance 'hunchentoot:easy-acceptor
;;                               :port port
;;                               :document-root "resources/")
;;                :ws-port ws-port)))

;; ;;
;; ;; models.lisp
;; ;;
;; ;; Imagine this is our DB interface.
;; ;;
;; (defclass product ()
;;   ((id :initform (string (gensym "ID-"))
;;        :accessor product-id)
;;    (title :initform ""
;;           :initarg :title
;;           :accessor title
;;           :type string)
;;    (done :initform nil
;;          :initarg :done
;;          :accessor done
;;          :type boolean)
;;    (weight :initform (1+ (random 4))
;;            ;; :initarg :weight
;;            :accessor weight
;;            :type integer
;;            :documentation "We give a weight to the item, only to print more elements on the page.")))

;; (defmethod print-object ((obj product) stream)
;;   (print-unreadable-object (obj stream :type t)
;;     (format stream "~a" (slot-value obj 'title))))

;; (defun make-product (title)
;;   (make-instance 'product :title title))

;; (defun find-product-by-id (id)
;;   (find id *products* :test #'equal :key #'product-id))

;; (defun delete-product-from-id (id)
;;   (delete id *products* :test #'equal :key #'product-id))

;; (defun search-products (q)
;;   "Search this query (string) inside the products' titles,
;;   Return the ones matching (a list)."
;;   (loop for item in *products*
;;      if (str:containsp q (title item)
;;                        :ignore-case t)
;;      collect item))

;; (defun create-products ()
;;   (loop for title in '("foo" "bar" "baz")
;;      collect (make-product title)))

;; ;;
;; ;; Start with data.
;; ;;
;; (setf *products* (create-products))

;; ;;
;; ;; end of the models interface.
;; ;;

;; ;;
;; ;; views / route
;; ;;
;; ;; We have one route: localhost:8080/products
;; ;;

;; (define-easy-handler (url/root :uri "/") ()
;;   (hunchentoot:redirect "/products"))

;; (define-easy-handler (products :uri "/products")
;;     ;; Actions:
;;     (add-new-task
;;      new-task
;;      check
;;      delete-product)
;;   (let ((add-new-product-p (and add-new-task
;;                                 new-task
;;                                 (string= add-new-task "add")
;;                                 (not (str:blankp new-task))))
;;         new-product)
;;     (log:info add-new-task new-task add-new-product-p (hunchentoot:get-parameters*))

;;     ;; Create a new product?
;;     (when add-new-product-p
;;       (setf new-product (make-product new-task))
;;       (setf *products* (append *products*
;;                                (list new-product))))

;;     ;; Toggle the "done" state?
;;     (when (str:non-blank-string-p check)
;;       (let* ((product (find-product-by-id check)))
;;         (print (setf (done product)
;;                      (not (done product))))))

;;     ;; Delete item.
;;     (when (str:non-blank-string-p delete-product)
;;       (log:info delete-product)
;;       (setf *products* (delete-product-from-id delete-product)))

;;     (djula:render-template* +products.html+ nil
;;                             :issr-id *id*
;;                             :ws-port *ws-port*
;;                             :products *products*
;;                             :products-weight (loop for item in *products*
;;                                                 sum (weight item))
;;                             :todos (loop for item in *products*
;;                                               unless (done item)
;;                                               collect item)
;;                             :add-new-task add-new-task)))

;; (define-easy-handler (api/messages :uri "/api/messages") ()
;;   (log:info (hunchentoot:get-parameters*))
;;   (format nil "<div> hello HTMX </div>"))

;; (define-easy-handler (mouse_entered :uri "/mouse_entered") ()
;;   (log:info (hunchentoot:get-parameters*))
;;   (format nil "<div> hello mouse !! </div>"))

;; (define-easy-handler (search_delay :uri "/search_delay")
;;     (q)
;;   (log:info (hunchentoot:get-parameters*))
;;   (format nil "<div> search result ! </div>")
;;   (djula:render-template* +searchresults.html+ nil
;;                           :products (search-products q)))
;; ;;
;; ;; and that's it.
;; ;;

(defun getenv-integer (env)
  (ignore-errors (parse-integer (uiop:getenv env))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Entry point (for executable).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun main (&key (port 8080 port-p) (ws-port 4433 ws-port-p))
  ;; main is called with Roswell or manually.
  ;; Check the ports in env.

  (unless port-p
    (setf port (or (getenv-integer "ISSR_PORT")
                   port)))
  (unless ws-port-p
    (setf ws-port (or (getenv-integer "ISSR_WS_PORT")
                      ws-port)))

  (uiop:format! t "Starting a great ISSR example on http://localhost:~a/products~&" port)

  ;; (handler-case
  ;;     (progn
  ;;       ;; (start-app :port port :ws-port ws-port)

  ;;       ;; NB: we need the following thread capture only for the binary,
  ;;       ;; running from sources is OK and it gets us the REPL if we don't use --non-interactive.
  ;;       ;;
  ;;       ;; Let the webserver run
  ;;       ;; (put its thread on the foreground, for the script not to instantly quit).
  ;;       ;; warning: hardcoded "hunchentoot".
  ;;       ;; (bt:join-thread (find-if (lambda (th)
  ;;       ;;                            (search "hunchentoot" (bt:thread-name th)))
  ;;       ;;                          (bt:all-threads)))
  ;;       )

  ;;   (usocket:address-in-use-error ()
  ;;     (format t "~&Address(es) already in use. Double check the app and websocket ports.~&"))
  ;;   (#+sbcl sb-sys:interactive-interrupt ()
  ;;           (progn
  ;;             (format *error-output* "Aborting. Hope you liked it!~&")
  ;;             (uiop:quit)))
  ;;   (error (c)
  ;;     (format t "~&An error occured:~&~a~&" c)))
  )
