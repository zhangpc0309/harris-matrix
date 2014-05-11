;;;; harris-matrix.lisp

;;   (in-package #:harris-matrix)

;;; "harris-matrix" goes here. Hacks and glory await!

(require "graph-dot")
(require "graph-matrix")
(require "cl-csv")

;; global variables will be set by configuration file
(defparameter *out-file* nil)
(defparameter *context-table-name* nil)
(defparameter *observation-table-name* nil)
(defparameter *inference-table-name* nil)
(defparameter *period-table-name* nil)
(defparameter *phase-table-name* nil)
(defparameter *context-table-header* nil)
(defparameter *observation-table-header* nil)
(defparameter *inference-table-header* nil)
(defparameter *period-table-header* nil)
(defparameter *phase-table-header* nil)
(defparameter *symbolize-unit-type* nil)
(defparameter *node-fill-by* nil)
(defparameter *label-break* nil)
(defparameter *color-scheme* nil)
(defparameter *color-space* nil)
(defparameter *label-color-dark* nil)
(defparameter *label-color-light* nil)
(defparameter *reachable-from* nil)
(defparameter *reachable-limit* nil)
(defparameter *reachable-color* nil)
(defparameter *reachable-not-color* nil)
(defparameter *url-include* nil)
(defparameter *url-default* nil)
(defparameter *graph-title* nil)
(defparameter *graph-labelloc* nil)
(defparameter *graph-style* nil)
(defparameter *graph-size* nil)
(defparameter *graph-ratio* nil)
(defparameter *graph-page* nil)
(defparameter *graph-dpi* nil)
(defparameter *graph-margin* nil)
(defparameter *graph-font-name* nil)
(defparameter *graph-font-size* nil)
(defparameter *graph-font-color* nil)
(defparameter *graph-splines* nil)
(defparameter *graph-bg-color* nil)
(defparameter *legend* nil)
(defparameter *legend-node-shape* nil)
(defparameter *edge-style* nil)
(defparameter *edge-with-arrow* nil)
(defparameter *edge-color* nil)
(defparameter *edge-font-name* nil)
(defparameter *edge-font-size* nil)
(defparameter *edge-font-color* nil)
(defparameter *node-style* nil)
(defparameter *node-color* nil)
(defparameter *node-font-name* nil)
(defparameter *node-font-size* nil)
(defparameter *node-font-color* nil)
(defparameter *node-shape-interface* nil)
(defparameter *node-shape-deposit* nil)
(defparameter *node-fill* nil)

;; constants
(defconstant +transparent+ (read-from-string "transparent"))
(defconstant +basal+ (read-from-string "basal"))
(defconstant +surface+ (read-from-string "surface"))
(defconstant +levels+ (read-from-string "levels"))
(defconstant +periods+ (read-from-string "periods"))
(defconstant +phases+ (read-from-string "phases"))
(defconstant +reachable+ (read-from-string "reachable"))
(defconstant +connected+ (read-from-string "connected"))
(defconstant +deposit+ (read-from-string "deposit"))
(defconstant +interface+ (read-from-string "interface"))
(defconstant +adjacent+ (read-from-string "adjacent"))
(defconstant +not-reachable+ (read-from-string "not-reachable"))


(defun hm-read-cnf-file (config-file-name)
  "Read csv file specified by CONFIG-FILE-NAME and set global
variables.  Return t if successful, nil otherwise."
  (when (probe-file config-file-name)
       (cl-csv:do-csv (row (probe-file config-file-name))
         (setf (symbol-value (read-from-string (first row)))
               (cond
                 ((string= "reachable" (second row)) +reachable+)
                 ((string= "periods" (second row)) +periods+)
                 ((string= "phases" (second row)) +phases+)
                 ((string= "levels" (second row)) +levels+)
                 ((string= "connected" (second row)) +connected+)
                 ((string= "t" (second row)) t)
                 ((string= "nil" (second row)) nil)
                 ((string= "" (second row)) nil)
                 ((every #'float-char-p (second row))
                  (read-from-string (second row)))
                 (t (second row)))))
       t))

(defun color-filter (col extra-quotes)
  "Returns a valid Graphviz dot color designator. The result is either an integer or a color name appended to a color space.  COL can either be an integer, in which case Brewer colors are assumed, or a string with a color name."
  (if (integerp col) col
      (if (eq (read-from-string col) +transparent+)
          col
          (if extra-quotes
              (format nil "\"/~a/~a\"" *color-space* col)
              (format nil "/~a/~a" *color-space* col)))))

(defun float-char-p (char)
  "Is CHAR plausibly part of a real number?"
  (or (digit-char-p char) (char= char #\,) (char= char #\.)))

(defun make-attribute (att)
  (format nil "~(~s~)" (if att att "")))

(defun constantly-format (x)
  (constantly (format nil "~s" (if x x ""))))

(defun node-fill-by-table (table contexts)
  (let ((ht (make-hash-table))
        (ret (make-hash-table)))
    (mapcar #'(lambda (x)
                (setf (gethash (read-from-string (first x)) ht)
                      (read-from-string (third x))))
            table)
    (mapcar #'(lambda (x)
                (setf (gethash (read-from-string (first x)) ret)
                      (gethash (read-from-string (fourth x)) ht)))
            contexts)
    ret))

(defun node-fill-by-reachable (graph)
  (let ((ret (make-hash-table))
        (reachable-list
         (cond 
           ((< *reachable-limit* 0)
            (graph-matrix:reachable-from
             graph
             (graph-matrix:to-reachability-matrix
              graph
              (make-instance 'graph-matrix:fast-matrix))
             *reachable-from*))
           ((eql *reachable-limit* 0) (list *reachable-from*))
           ((eql *reachable-limit* 1)
            (cons *reachable-from*
                  (graph-matrix:reachable-from
                   graph
                   (graph-matrix:to-adjacency-matrix
                    graph
                    (make-instance 'graph-matrix:fast-matrix))
                   *reachable-from*)))
           (t (graph-matrix:reachable-from
               graph (graph-matrix:to-reachability-matrix
                      graph (make-instance 'graph-matrix:fast-matrix)
                      :limit *reachable-limit*)
               *reachable-from*)))))
    (dolist (node reachable-list)
      (setf (gethash (read-from-string (format nil "~a" node)) ret)
            (color-filter *reachable-color* nil)))
    (dolist (node (set-difference (graph:nodes graph) reachable-list))
      (setf (gethash (read-from-string (format nil "~a" node)) ret)
            (color-filter *reachable-not-color* nil)))
    ret))

(defun node-fill-by-connected ()
  (let ((ret (make-hash-table))
        (reachable-list (graph:connected-component graph *reachable-from*
                                                   :type :unilateral)))
    (dolist (node reachable-list)
      (setf (gethash (read-from-string (format nil "~a" node)) ret)
            (color-filter *reachable-color* nil)))
    (dolist (node (set-difference (graph:nodes graph) reachable-list))
      (setf (gethash (read-from-string (format nil "~a" node)) ret)
            (color-filter *reachable-not-color* nil)))
    ret))

(defun set-same-ranks (rank-list table)
  (mapcar #'(lambda (x)
              (push (graph-dot::make-rank :value "same"
                                          :node-list (list (first x) (second x)))
               rank-list))
          table))

(defun set-other-ranks (rank-list table)
  (mapcar #'(lambda (x)
              (when (or (eq (read-from-string (third x)) +basal+)
                        (eq (read-from-string (third x)) +surface+))
                (push (graph-dot::make-rank
                       :value
                       (cond
                         ((eq (read-from-string (third x)) +basal+) "sink")
                         ((eq (read-from-string (third x)) +surface+) "source"))
                       :node-list
                       (list (if (stringp (first x))
                                 (read-from-string
                                  (format nil "~:@(~s~)" (first x)))
                                 (first x))))
                      rank-list)))
          table))

(defun set-node-shapes (table)
  (let ((ret (make-hash-table)))
    (mapcar #'(lambda (x)
                (setf (gethash (read-from-string (first x)) ret) 
                      (cond ((eq +deposit+ (read-from-string (second x)))
                             *node-shape-deposit*)
                            ((eq +interface+ (read-from-string (second x)))
                             *node-shape-interface*))))
            table)
    ret))

(defun get-node-urls-from (table)
  (let ((ret (make-hash-table)))
    (dolist (node table)
      (setf (gethash (read-from-string (first node)) ret)
            (if (string= (sixth node) "")
                (if *url-default* *url-default* "")
                (sixth node))))
    ret))

(defun get-arc-urls-from (table)
  (let ((ret (make-hash-table :test #'equal)))
    (dolist (arc table)
      (setf (gethash (list (read-from-string (first arc))
                           (read-from-string (second arc))) ret)
            (if (string= (third arc) "")
                (if *url-default* *url-default* "") (third arc))))
    ret))

(defun make-legend-for (table graph nodes units urls)
  (mapcar #'(lambda (x)
              (setf (gethash (read-from-string (second x)) nodes)
                    (read-from-string (third x)))
              (setf (gethash (read-from-string (second x)) units)
                    *legend-node-shape*)
              (when *url-include*
                (setf (gethash (read-from-string (second x)) urls)
                      (fourth x)))
              (graph:add-node graph (read-from-string (second x))))
          table))

(defun make-reachable-legend (graph nodes units urls)
  (setf (gethash +reachable+ nodes) *reachable-color*)
  (setf (gethash +not-reachable+ nodes) *reachable-not-color*)
  (setf (gethash +reachable+ units) *legend-node-shape*)
  (setf (gethash +not-reachable+ units) *legend-node-shape*)
  (when *url-include*
    (setf (gethash +reachable+ urls) (if *url-default* *url-default* ""))
    (setf (gethash +not-reachable+ urls) (if *url-default* *url-default* "")))
  (push (graph-dot::make-rank :value "sink"
                              :node-list (list +reachable+ +not-reachable+))
        ranks)
  (graph:add-node graph +reachable+)
  (graph:add-node graph +not-reachable+))

(defun hm-draw (cnf-file-path)
  "Write a dot file"
  (let ((rejected)
        (ranks)
        (node-fills)
        (unit-types)
        (arc-urls)
        (node-urls)
        (graph (graph:populate (make-instance 'graph:digraph)))
        (context-table)
        (observation-table)
        (inference-table)
        (period-table)
        (phase-table))
    (if (hm-read-cnf-file cnf-file-path)
        (progn
          ;; required tables
          (if (probe-file *context-table-name*)
              (setq context-table
                    (cl-csv:read-csv (probe-file *context-table-name*)
                                     :skip-first-p *context-table-header*))
              (return-from hm-draw (format nil "Unable to read ~a"
                                           *context-table-name*)))
          (if (probe-file *observation-table-name*)
              (setq observation-table
                    (cl-csv:read-csv (probe-file *observation-table-name*)
                                     :skip-first-p *observation-table-header*))
              (return-from hm-draw (format nil "Unable to read ~a"
                                           *observation-table-name*)))
          ;; optional tables
          (if (and *inference-table-name* (probe-file *inference-table-name*))
              (setq inference-table
                    (cl-csv:read-csv (probe-file *inference-table-name*)
                                     :skip-first-p *inference-table-header*))
              (return-from hm-draw (format nil "Unable to read ~a"
                                           *inference-table-name*)))
          (if (and *period-table-name* (probe-file *period-table-name*))
              (setq period-table
                    (cl-csv:read-csv (probe-file *period-table-name*)
                                     :skip-first-p *period-table-header*))
              (return-from hm-draw (format nil "Unable to read ~a"
                                           *period-table-name*)))
          (if (and *phase-table-name* (probe-file *phase-table-name*))
              (setq phase-table
                    (cl-csv:read-csv (probe-file *phase-table-name*)
                                     :skip-first-p *phase-table-header*))
              (return-from hm-draw (format nil "Unable to read ~a"
                                           *phase-table-name*)))
          ;; create graph
          (dolist (node context-table)
            (graph:add-node graph (read-from-string (first node))))
          (dolist (arc observation-table rejected)
            (graph:add-edge graph
                            (list (read-from-string (first arc))
                                  (read-from-string (second arc))))
            (unless rejected
              (and (graph:cycles graph) (push arc rejected))))
                                       
          (if rejected (format t "A cycle includes ~a" (pop rejected))
              (progn                    ; create dot file
                (set-same-ranks ranks inference-table)
                (set-other-ranks ranks context-table)
                (when *node-fill-by*    ; fill nodes
                  (setq node-fills
                        (cond ((eq *node-fill-by* +levels+)
                               (graph:levels graph))
                              ((eq *node-fill-by* +periods+)
                               (node-fill-by-table period-table context-table))
                              ((eq *node-fill-by* +phases+)
                               (node-fill-by-table phase-table context-table))
                              ((and *reachable-from*
                                    (eq *node-fill-by* +reachable+))
                               (node-fill-by-reachable graph))
                              ((and *reachable-from*
                                    (eq *node-fill-by* +connected+))
                               (node-fill-by-connected))
                              (t (return-from hm-draw
                                   (format t "Incorrect *node-fill-by* value: ~a"
                                           *node-fill-by*))))))
                (when *symbolize-unit-type* ; node shapes
                  (setq unit-types (set-node-shapes context-table)))
                (when *url-include*     ; add url information
                  (setq node-urls (get-node-urls-from context-table))
                  (setq arc-urls (get-arc-urls-from observation-table)))
                (when *legend*
                  (cond ((eq *node-fill-by* +periods+)
                         (make-legend-for period-table graph node-fills
                                          unit-types node-urls))
                        ((eq *node-fill-by* +phases+)
                         (make-legend-for phase-table graph node-fills
                                          unit-types node-urls))
                        ((and *reachable-from* (eq *node-fill-by* +reachable+))
                         (make-reachable-legend graph node-fills
                                                unit-types node-urls))))
                (graph-dot:to-dot-file  ; write the dot file
                 graph *out-file*
                 :ranks ranks
                 :attributes
                 (list
                  (cons :style (make-attribute *graph-style*))
                  (cons :colorscheme (make-attribute *color-scheme*))
                  (cons :dpi (make-attribute *graph-dpi*))
                  (cons :URL (make-attribute *url-default*))
                  (cons :margin (make-attribute *graph-margin*))
                  (cons :bgcolor
                        (format nil "~(~s~)"
                                (if *graph-bg-color*
                                    (color-filter
                                     *graph-bg-color* nil) "")))
                  (cons :fontname (make-attribute *graph-font-name*))
                  (cons :fontsize (make-attribute *graph-font-size*))
                  (cons :fontcolor
                        (format nil "~(~s~)"
                                (if *graph-font-color*
                                    (color-filter *graph-font-color* nil) "")))
                  (cons :splines (make-attribute *graph-splines*))
                  (cons :page (make-attribute *graph-page*))
                  (cons :size (make-attribute *graph-size*))   
                  (cons :ratio (make-attribute *graph-ratio*))
                  (cons :label (make-attribute *graph-title*))
                  (cons :labelloc (make-attribute *graph-labelloc*)))
                 :edge-attrs (list
                              (cons :style
                                    (constantly-format *edge-style*))
                              (cons :arrowhead
                                    (constantly-format *edge-with-arrow*))
                              (cons :colorscheme
                                    (constantly-format *color-scheme*))
                              (cons :color
                                    (constantly-format
                                     (if *edge-color*
                                         (color-filter *edge-color* nil)
                                         "")))
                              (cons :fontname
                                    (constantly-format *edge-font-name*))
                              (cons :fontsize
                                    (constantly-format *edge-font-size*))
                              (cons :fontcolor
                                    (constantly-format
                                     (if *edge-font-color*
                                         (color-filter *edge-font-color* nil)
                                         "")))
                              (cons :URL (if (and *url-include* arc-urls
                                                  (> (hash-table-count arc-urls) 0))
                                             (lambda (e) 
                                               (format nil "~s"
                                                       (gethash e arc-urls)))
                                             (constantly-format ""))))
                 :node-attrs (list
                              (cons :shape
                                    (if (and *symbolize-unit-type* unit-types
                                             (> (hash-table-count unit-types) 0))
                                        (lambda (n) 
                                          (format nil "~(~s~)"
                                                  (gethash n unit-types)))
                                        (constantly-format *node-shape-deposit*)))
                              (cons :style (constantly-format *node-style*))
                              (cons :fontname (constantly-format *node-font-name*))
                              (cons :fontsize (constantly-format *node-font-size*))
                              (cons :colorscheme
                                    (constantly-format *color-scheme*))
                              (cons :color
                                    (constantly-format
                                     (if *node-color*
                                         (color-filter *node-color* nil)
                                         "")))
                              (cons :fillcolor
                                    (if (and node-fills
                                             (> (hash-table-count node-fills) 0))
                                        (lambda (n) (+ 1 (gethash n node-fills)))
                                        (constantly
                                         (if *node-fill*
                                             (color-filter *node-fill* t)
                                             ""))))
                              (cons :fontcolor
                                    (if (and node-fills
                                             (> (hash-table-count node-fills) 0))
                                        (lambda (n)
                                          (if (<= *label-break*
                                                  (gethash n node-fills))
                                              (color-filter *label-color-light* t)
                                              (color-filter *label-color-dark* t)))
                                        (constantly
                                         (if *node-font-color*
                                             (color-filter *node-font-color* t) ""))))
                              (cons :URL 
                                    (if (and *url-include* node-urls
                                             (> (hash-table-count node-urls) 0))
                                        (lambda (n) (format nil "~s"
                                                       (gethash n node-urls)))
                                        (constantly-format "")))))))
          (format t "Wrote ~a" *out-file*))
        (format t "Unable to read from ~a" cnf-file-path))))
