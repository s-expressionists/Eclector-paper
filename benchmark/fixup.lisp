;;; Run with sbcl --control-stack-size 256

;;; Every labeled object is immediately recognizable as circular
(defun make-quadratic-fixup-1 (limit)
  (with-output-to-string (stream)
    (labels ((rec (count)
               (cond ((= count (1+ limit))
                      (format stream "~{#~D#~^ ~}"
                              (loop :for i :from 1 :below count
                                    :collect i)))
                     (t
                      (format stream "#~D=(" count)
                      (rec (1+ count))
                      (format stream ")")))))
      (rec 1))))

;;; Labeled objects become circular only after descendant labeled
;;; objects have already been encountered.
(defun make-quadratic-fixup-2 (limit)
  (with-output-to-string (stream)
    (labels ((rec (count)
               (cond ((= count (1+ limit))
                      (format stream "1 2 3"))
                     (t
                      (format stream "#~D=(" count)
                      (rec (1+ count))
                      (format stream " #~D#)" count)))))
      (rec 1))))

(defun run-test-case (&key (reader  'read-from-string)
                           (variant 'make-quadratic-fixup-1)
                           (size    690))
  (let ((input (funcall variant size)))
    (the-cost-of-nothing:benchmark (funcall reader input))))

(let ((measurements (make-array 0 :adjustable t)))
  (loop :for reader :in '(read-from-string eclector.reader:read-from-string)
        :do (loop :for variant :in '(make-quadratic-fixup-1
                                     make-quadratic-fixup-2)
                  :do (format *trace-output* "~S - ~A~%" reader variant)
                      (loop :for log-size :from 0 :to 12
                            :for size = (expt 2 log-size)
                            :for time = (run-test-case :reader  reader
                                                       :variant variant
                                                       :size    size)
                            :do (format *trace-output* " ~4:D - ~,3F s~%"
                                        size
                                        time)
                                (adjust-array measurements (max (array-total-size measurements)
                                                                (1+ log-size))
                                              :initial-element nil)
                                (when (null (aref measurements log-size))
                                  (setf (aref measurements log-size) (list size)))
                                (let ((cell (aref measurements log-size)))
                                  (setf (cdr cell) (append (cdr cell) (list time)))))))
  (with-open-stream (stream (open "fixup.txt" :direction :output
                                              :if-exists :supersede))
    (loop :for cell :across measurements
          :do (format stream "~D~{ ~,6F~}~%" (first cell) (rest cell)))))


(when nil
  (progn
    (print (lisp-implementation-version))
    (print (list :input1 3 (make-quadratic-fixup-1 3)))
    (print (list :input1 4 (make-quadratic-fixup-1 4)))
    (print (list :input2 3 (make-quadratic-fixup-2 3)))
    (print (list :input2 4 (make-quadratic-fixup-2 4)))))

(when nil
  (let ((*trace-output* *standard-output*))
    (time (progn (read-from-string (make-quadratic-fixup-1 690)) nil)))
  (let ((*trace-output* *standard-output*))
    (time (progn (read-from-string (make-quadratic-fixup-2 690)) nil))))
