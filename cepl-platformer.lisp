;;;; cepl-platformer.lisp

(in-package #:cepl-platformer)

(defvar *running* nil)

(defparameter +quad-stream+ (nineveh:get-quad-stream-v2))
(defvar *tile-textures* (make-hash-table :test 'equal))

(defvar *entities* nil)

(defun-g quad-vertex-shader ((uvs :vec2))
  (values (v! uvs 0 0)
          uvs))

(defun-g textured-frag-shader ((uvs :vec2))
  (v! 1 0 0 0))

(defpipeline-g textured-quad-pipeline ()
  :vertex (quad-vertex-shader :vec2)
  :fragment (textured-frag-shader :vec2))

(defun get-texture-sampler (pathname)
  (let ((hash (gethash pathname *tile-textures*)))
    (if hash
        (sample hash)
        (setf (gethash pathname *tile-textures*) (dirt:load-image-to-texture pathname)))))

(defclass textured ()
  ((texture-path :initarg :texture-path :accessor texture-path
                 :initform (error "Must provide a texture."))))

(defclass player (textured)
  ((pos :initarg :pos :accessor pos)
   (vel :initarg :vel :accessor vel)))

(defgeneric draw (obj))

(defmethod draw ((obj textured))
  (map-g #'textured-quad-pipeline +quad-stream+))

(defclass world ()
  ((tiles :initarg :tiles)))

(defun init ()
  (setf *running* t)
  (setf *entities* nil)
  (push (make-instance 'player
                       :pos (v2! 0 0)
                       :vel (v2! 0 0)
                       :texture-path "./res/Players/Player Blue/playerBlue_stand.png") *entities*))

(defun step-game ()
  (step-host)
  (update-repl-link)
  (clear)
  (loop :for entity :in *entities*
        :do (draw entity))
  (swap))

(defun run-loop ()
  (init)
  (slynk-mrepl::send-prompt (find (bt:current-thread) (slynk::channels)
                                  :key #'slynk::channel-thread))
  (loop :while (and *running* (not (shutting-down-p)))
        :do (continuable (step-game))))

(defun stop-loop ()
  (setf *running* nil))
