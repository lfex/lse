(defmodule lse-util
  (export all))

(defun get-version ()
  (lutil:get-app-version 'lse))

(defun get-versions ()
  (++ (lutil:get-versions)
      `(#(lse ,(get-version)))))
