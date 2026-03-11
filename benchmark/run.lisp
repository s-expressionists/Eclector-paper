(defvar *cases*
  '(("flexi-streams" . #P"enc-cn-tbl.lisp")
    ("screamer"      . #P"screamer.lisp")))

(ql:quickload (list* "alexandria"
                     "eclector"
                     "eclector-concrete-syntax-tree"
                     "the-cost-of-nothing"
                     (mapcar #'first *cases*))
              :silent t)

(defun call-with-open-stream (system file continuation)
  (let* ((directory (ql:where-is-system system))
         (filename  (merge-pathnames file directory))
         (content   (alexandria:read-file-into-string filename)))
    (format *trace-output* " ~7:D lines" (count #\Newline content))
    #+sbcl (sb-ext:gc :full t)
    #+ccl  (gc)
    (the-cost-of-nothing:benchmark
     (with-input-from-string (stream content)
       (funcall continuation stream)))))

(defun test-cases (continuation)
  (loop :for (system . file) :in *cases*
        :do (format *trace-output* "  ~14A ~16A" system file)
            (let ((time (call-with-open-stream system file continuation)))
              (format *trace-output* "    ~,3F s~%" time))))

(defun read-with-intrinsic-reader ()
  (format *trace-output* "~A ~A builtin reader~%"
          (lisp-implementation-type) (lisp-implementation-version))
  (test-cases
   (lambda (stream)
     (loop :for form = (read stream nil stream)
           :until (eq form stream)))))

(defun read-with-eclector ()
  (format *trace-output* "~A ~A Eclector~%"
          (lisp-implementation-type) (lisp-implementation-version))
  (test-cases
   (lambda (stream)
     (loop :for form = (eclector.reader:read stream nil stream)
           :until (eq form stream)))))

(defun read-with-eclector/cst ()
  (format *trace-output* "~A ~A Eclector + CST~%"
          (lisp-implementation-type) (lisp-implementation-version))
  (test-cases
   (lambda (stream)
     (loop :for form = (eclector.concrete-syntax-tree:read
                        stream nil stream)
           :until (eq form stream)))))

(read-with-intrinsic-reader)

(read-with-eclector)

(read-with-eclector/cst)
