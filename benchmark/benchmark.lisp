(setf *default-pathname-defaults* #P"~/Projects/\\[2026\\]paper-els-eclector/benchmark/")

(uiop:run-program
 '("/usr/bin/sbcl"
   "--noinform"
   "--load" "/home/jmoringe/.local/share/common-lisp/quicklisp/setup.lisp"
   "--script" "run.lisp")
 :output    *standard-output*
 :error     *error-output*
 :directory *default-pathname-defaults*)

(uiop:run-program
 '("/home/jmoringe/opt/ccl/lx86cl64"
   "-b" "-Q"
   "-l" "/home/jmoringe/.local/share/common-lisp/quicklisp/setup.lisp"
   "-l" "run.lisp" )
 :output    *standard-output*
 :error     *error-output*
 :directory *default-pathname-defaults*)

#+no (uiop:run-program
 '("/usr/bin/ecl"
   "-q"
   "--load" "/home/jmoringe/.local/share/common-lisp/quicklisp/setup.lisp"
   "--load" "run.lisp")
 :output    *standard-output*
 :error     *error-output*
 :directory *default-pathname-defaults*)
