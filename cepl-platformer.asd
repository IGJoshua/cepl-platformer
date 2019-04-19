;;;; cepl-platformer.asd

(asdf:defsystem #:cepl-platformer
  :description "Describe cepl-platformer here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:cepl #:cepl.sdl2 #:nineveh #:dirt #:rtg-math)
  :components ((:file "package")
               (:file "cepl-platformer")))
