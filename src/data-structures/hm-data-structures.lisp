;;; hm-data-structures.lisp

;; Copyright (C) Thomas Dye 2017

;; Licensed under the Gnu Public License Version 3 or later

(in-package #:hm)

(defun classifiers ()
  "Returns an fset set of the hm classifiers in the standard hm configuration."
  (let ((opts (options (empty-configuration) "Graphviz sequence classification"))
        (ret (fset:empty-set)))
    (dolist (opt opts)
      (setf ret (fset:with ret opt)))
    ret))

(defun matrix-classes ()
  "hm classifications that require a graph matrix."
  (fset:set "distance" "reachable" "adjacent"))

(defun vector-classes ()
  "hm classifications that require a vector."
  (fset:set "levels" "units" "periods" "phases"))

(defun color-attributes ()
  "Graphviz attributes that expect a color string."
  (fset:set "color" "fillcolor" "fontcolor"))

(defun category-attributes ()
  "Graphviz attributes that expect a category string."
  (fset:set "style" "shape" "arrowhead"))

(defun numeric-attributes ()
  "Graphviz attributes that expect a numeric value."
  (fset:set "fontsize" "penwidth"))

(defun create-distance-matrix (seq)
  "Returns a distance matrix of the directed graph using the instructions in the
configured sequence, SEQ."
  (let ((graph (archaeological-sequence-graph seq))
        (cfg (archaeological-sequence-configuration seq)))
    (graph-matrix:to-distance-matrix graph (new-matrix (fast-matrix-p cfg)))))

(defun create-reachability-matrix (seq)
  "Returns a reachability matrix of the directed graph, GRAPH, using the
  instructions in the user's configuration, CFG."
  (let ((limit (reachable-limit (archaeological-sequence-configuration seq)))
        (graph (archaeological-sequence-graph seq))
        (cfg (archaeological-sequence-configuration seq)))
    (if (or (not limit) (< limit 2))
        (graph-matrix:to-reachability-matrix
         graph (new-matrix (fast-matrix-p cfg)))
        (graph-matrix:to-reachability-matrix
         graph (new-matrix (fast-matrix-p cfg)) :limit limit))))

(defun create-adjacency-matrix (seq)
  "Returns an adjacency matrix of the directed graph, GRAPH, using the
instructions in the user's configuration, CFG."
  (let ((graph (archaeological-sequence-graph seq))
          (cfg (archaeological-sequence-configuration seq)))
    (graph-matrix:to-adjacency-matrix graph (new-matrix (fast-matrix-p cfg)))))

;; (defun create-strong-component-matrix (seq)
;;   "Returns a strong-component-matrix of the directed graph, GRAPH, using
;;   instructions in the user's configuration, CFG."
;;   (let ((graph (archaeological-sequence-graph seq))
;;         (cfg (archaeological-sequence-configuration seq)))
;;     (graph-matrix:to-strong-component-matrix
;;      graph (new-matrix (fast-matrix-p cfg)))))

(defun make-node-index (graph)
  "Returns an fset map where the key is a node of graph GRAPH and the
value is an index into the matrix representation of GRAPH."
  (let ((counter -1)
        (node-index (fset:empty-map)))
    (mapc
     (lambda (node)
       (setf node-index (fset:with node-index (incf counter) node)))
     (graph:nodes graph))
    node-index))

(defun make-map (seq element dot-attr graph-type user-class)
  "Return a closure for the classification, USER-CLASS, that can be passed
directly to graph-dot for the attribute, DOT-ATTR, of the graph ELEMENT. ELEMENT
is one of `node', `edge'."
  (let ((cfg (archaeological-sequence-configuration seq)))
    (cond
      ((equal user-class "distance")
       (make-distance-map seq element dot-attr graph-type))
      ((equal user-class "adjacent")
       (make-adjacent-map cfg element dot-attr graph-type user-class))
      ((equal user-class "reachable")
       (make-reachable-map cfg element dot-attr graph-type user-class))
      ((equal user-class "units") (make-units-map cfg element dot-attr))
      ((equal user-class "levels") (make-levels-map seq element dot-attr))
      ((equal user-class "phases") (make-phases-map cfg element dot-attr))
      ((equal user-class "periods") (make-periods-map cfg element dot-attr)))))

(defun make-reachable-map (seq element dot-attr graph-type user-class)
  "Return a closure for a reachability classification, USER-CLASS, for the
attribute, DOT-ATTR, of the graph element, ELEMENT. ELEMENT is one of `node',
`edge'."
  (let* ((cfg (archaeological-sequence-configuration seq))
         (graph (archaeological-sequence-graph seq))
         (matrix (create-reachability-matrix seq))
         (from-node (reachable-from-node cfg))
         (cls (concatenate 'string element "-" dot-attr "-by"))
         (node-index (make-node-index graph))
         (node-p (equal element "node"))
         (edge-node
           (get-option cfg "Graphviz sequence edge attributes" "edge-classify-by"))
         (origin (lookup-graphviz-option
                  cfg element "origin" graph-type cls user-class))
         (reachable (lookup-graphviz-option
                    cfg element "reachable" graph-type cls user-class))
         (not-reachable (lookup-graphviz-option
                        cfg element "not-reachable" graph-type cls user-class)))
    (cond
      ((fset:contains? (color-attributes) dot-attr)
       (let ((scheme (lookup-graphviz-option
                      cfg element "colorscheme" graph-type user-class user-class)))
         #'(lambda (x)
             (let* ((color (graph-matrix:matrix-ref
                            matrix (fset:@ node-index from-node)
                            (if node-p (fset:@ node-index x)
                                (if (equal edge-node "from")
                                    (fset:@ node-index (nth 0 x))
                                    (fset:@ node-index (nth 1 x)))))))
               (graphviz-color-string (case color
                                        (0 origin)
                                        (1 reachable)
                                        (otherwise not-reachable))
                                      scheme 3)))))
      ((fset:contains? (fset:union (category-attributes) (numeric-attributes)) dot-attr)
       #'(lambda (x)
           (let ((index (graph-matrix:matrix-ref
                         matrix (fset:@ node-index from-node)
                         (if node-p (fset:@ node-index x)
                             (if (equal edge-node "from")
                                 (fset:@ node-index (nth 0 x))
                                 (fset:@ node-index (nth 1 x)))))))
             (case index
               (0 origin)
               (1 reachable)
               (otherwise not-reachable)))))
      (t (error "Error: Unable to make reachable map.")))))

(defun make-adjacent-map (seq element dot-attr graph-type user-class)
  "Return a closure for an adjacency classification, USER-CLASS, for the
attribute, DOT-ATTR, of the graph ELEMENT. ELEMENT is one of `node', `edge'."
  (let* ((cfg (archaeological-sequence-configuration seq))
         (graph (archaeological-sequence-graph seq))
         (matrix (create-adjacency-matrix seq))
         (node-index (make-node-index graph))
         (from-node (reachable-from-node cfg))
         (cls (concatenate 'string element "-" dot-attr "-by"))
         (node-p (equal element "node"))
         (edge-node
           (get-option cfg "Graphviz sequence edge attributes" "edge-classify-by"))
         (origin (lookup-graphviz-option
                  cfg element "origin" graph-type
                  cls user-class))
         (adjacent (lookup-graphviz-option
                    cfg element "adjacent" graph-type cls user-class))
         (not-adjacent (lookup-graphviz-option
                        cfg element "not-adjacent" graph-type cls user-class)))
    (cond
      ((fset:contains? (color-attributes) dot-attr)
       (let ((scheme (lookup-graphviz-option
                      cfg element "colorscheme" graph-type cls user-class)))
         #'(lambda (x)
             (let* ((color (graph-matrix:matrix-ref
                            matrix (fset:@ node-index from-node)
                            (if node-p (fset:@ node-index x)
                                (if (equal edge-node "from")
                                    (fset:@ node-index (nth 0 x))
                                    (fset:@ node-index (nth 1 x)))))))
               (graphviz-color-string (case color
                                        (0 origin)
                                        (1 adjacent)
                                        (otherwise not-adjacent))
                                      scheme 3)))))
      ((fset:contains? (fset:union (category-attributes) (numeric-attributes)) dot-attr)
       #'(lambda (x)
           (let ((index (graph-matrix:matrix-ref
                         matrix (fset:@ node-index from-node)
                         (if node-p (fset:@ node-index x)
                                (if (equal edge-node "from")
                                    (fset:@ node-index (nth 0 x))
                                    (fset:@ node-index (nth 1 x)))))))
             (case index
               (0 origin)
               (1 adjacent)
               (otherwise not-adjacent)))))
      (t (error "Error: Unable to make adjacency map.")))))

(defun category-attribute-map (element dot-attr)
  (cond
    ((and (string= element "node") (string= dot-attr "style"))
     (graphviz-node-style-map))
    ((and (string= element "node") (string= dot-attr "shape"))
     (graphviz-node-shape-map))
    ((and (string= element "edge") (string= dot-attr "style"))
     (graphviz-edge-style-map))
    ((and (string= element "edge") (string= dot-attr "arrowhead"))
     (graphviz-arrow-shape-map))))

(defun make-distance-map (seq element dot-attr graph-type)
  "Return a closure for a distance classification for the attribute, DOT-ATTR,
of the graph ELEMENT. ELEMENT is one of `node', `edge'."
  (let* ((cfg (archaeological-sequence-configuration seq))
         (graph (archaeological-sequence-graph seq))
         (matrix (create-distance-matrix seq))
         (node-index (make-node-index graph))
         (node-p (equal element "node"))
         (edge-node
           (get-option cfg "Graphviz sequence edge attributes" "edge-classify-by"))
         (from-node (reachable-from-node cfg)))
    (cond
      ((fset:contains? (color-attributes) dot-attr)
       (let ((max-distance (max-value matrix))
             (scheme (lookup-graphviz-option cfg element "colorscheme" graph-type)))
         #'(lambda (x)
             (let ((color (graph-matrix:matrix-ref
                           matrix (fset:@ node-index from-node)
                           (fset:@ node-index x))))
               (graphviz-color-string color scheme (+ 1 max-distance))))))
      ((fset:contains? (category-attributes) dot-attr)
       (let ((map (category-attribute-map element dot-attr)))
         #'(lambda (x)
             (let ((index (graph-matrix:matrix-ref
                           matrix (fset:@ node-index from-node)
                           (if node-p (fset:@ node-index x)
                                (if (equal edge-node "from")
                                    (fset:@ node-index (nth 0 x))
                                    (fset:@ node-index (nth 1 x)))))))
               (fset:@ map (mod index (fset:size map)))))))
      ((fset:contains? (numeric-attributes) dot-attr)
       (let ((min (if (string= dot-attr "penwidth")
                      (penwidth-min cfg element)
                      (fontsize-min cfg element)))
             (max (if (string= dot-attr "penwidth")
                      (penwidth-max cfg element)
                      (fontsize-max cfg element)))
             (interval (/ 1 (max-value matrix))))
         #'(lambda (x)
             (let ((index (graph-matrix:matrix-ref
                           matrix (fset:@ node-index from-node)
                           (if node-p (fset:@ node-index x)
                                (if (equal edge-node "from")
                                    (fset:@ node-index (nth 0 x))
                                    (fset:@ node-index (nth 1 x)))))))
               (+ min (* (- max min) (* interval index)))))))
      (t (error "Error: Unable to make distance map.")))))

(defun max-value (matrix)
  "Return the maximum value in a matrix."
  (let ((rows (graph-matrix:matrix-n-rows matrix))
        (cols (graph-matrix:matrix-n-cols matrix))
        (max-val 0))
    (loop :for i :below rows :do
      (loop :for j :below cols :do
        (let ((this-val (graph-matrix:matrix-ref matrix i j)))
          (when (> this-val max-val))
            (setf max-val this-val))))))

(defun make-units-map (cfg element dot-attr)
  "Return an fset map for a unit classification, whose key is an integer and
value is a string appropriate for the attribute, DOT-ATTR, of the graph ELEMENT.
ELEMENT is one of `node', `edge'."
  (let ((map (fset:empty-map)))))

(defun make-levels-map (seq element dot-attr)
  "Return an fset map for a levels classification, whose key is an integer and
value is a string appropriate for the attribute, DOT-ATTR, of the graph ELEMENT.
ELEMENT is one of `node', `edge'."
  (let ((map (fset:empty-map))
        (cfg (archaeological-sequence-configuration seq))
        (graph (archaeological-sequence-graph seq))
        (max-levels))))

(defun make-phases-map (cfg element dot-attr)
  "Return an fset map for a phases classification, whose key is an integer and
value is a string appropriate for the attribute, DOT-ATTR, of the graph ELEMENT.
ELEMENT is one of `node', `edge'."
  (let ((map (fset:empty-map)))))

(defun make-periods-map (cfg element dot-attr)
  "Return an fset map for a periods classification, whose key is an integer and
value is a string appropriate for the attribute, DOT-ATTR, of the graph ELEMENT.
ELEMENT is one of `node', `edge'."
  (let ((map (fset:empty-map)))))

(defun make-map-string (cfg string dot-attr)
  (if (fset:contains? (color-attributes) dot-attr)
      (graphviz-sequence-graph-color (cfg dot-attr))
      (string)))

(defun make-vector (cfg graph user-class)
  (sleep 1))

(defun make-matrix (seq user-class)
  "Return a graph-matrix matrix appropriate for USER-CLASS, given the
  information on the user's configuration and a directed graph from SEQ."
  (let ((cfg (archaeological-sequence-configuration seq))
        (graph (archaeological-sequence-graph seq))))
  (cond
    ((string= "distance" user-class) (create-distance-matrix cfg graph))
    ((string= "reachable" user-class) (create-reachability-matrix cfg graph))
    ((string= "adjacent" user-class) (create-adjacency-matrix cfg graph))))

(defun get-from-map (map key)
  (fset:lookup map key))

(defun get-from-vector (vector element)
  (fset:lookup vector element))

(defun get-from-matrix (matrix from to)
  (sleep 1))

(defun tables-to-map (contexts other-table table-type)
  "Given a CONTEXTS table, an OTHER-TABLE, and a TABLE-TYPE in
`periods' or `phases', return an fset map where the key is the context
and the value is either the period or phase of the context."
  (let ((ht (fset:empty-map))
        (ret (fset:empty-map))
        (n (cond
            ((string= table-type "periods") 3)
            ((string= table-type "phases") 4)
            (t (error "Error: unrecognized table type")))))
    (mapcar #'(lambda (x)
                (setf ht (fset:with ht (nth 0 x) (nth 2 x))))
            other-table)
    (mapcar #'(lambda (x)
                (setf ret
                      (fset:with ret (symbolicate (nth 0 x))
                                 (read-from-string (fset:@ ht (nth n x))))))
            contexts)
    ret))

(defun alist-to-map (alist)
  "Given an assoc-list, ALIST, return the corresponding fset map."
  (let ((ret (fset:empty-map)))
    (mapc #'(lambda (pair)
              (setq ret (fset:with ret (car pair) (cdr pair))))
          alist)
    ret))

(defun context-type-to-map (contexts)
  "Given a context table, CONTEXTS, return an fset map where the key
  is the context and the value is 0 if the unit-type is `deposit' or 1
  if the unit-type is `interface'."
  (let ((ret (fset:empty-map)))
    (mapcar #'(lambda (x)
                (setf ret
                      (fset:with ret (symbolicate (nth 0 x))
                                 (cond
                                   ((string= (nth 1 x) "deposit") 0)
                                   ((string= (nth 1 x) "interface") 1)))))
            contexts)
    ret))


;; ;; Needs work!
;; (defun process-user-value (value dot-attr option seq &key element)
;;   (if (fset:contains? (fset:set "color" "fillcolor" "fontcolor")
;;                       dot-attr)
;;       (let* ((section (if (equal element :node)
;;                           "Graphviz sequence node attributes"
;;                         "Graphviz sequence edge attributes"))
;;              (scheme (get-option (archaeological-sequence-configuration seq)
;;                                  section
;;                                  "colorscheme"))
;;              (classifiers (archaeological-sequence-classifiers seq))
;;              (range (unless (emptyp option)
;;                       (round (1+ (- (fset:greatest (fset:range (fset:@ classifiers option)))
;;                                     (fset:least (fset:range (fset:@ classifiers option)))))))))
;;         (if (and option
;;                  (not (emptyp scheme)))
;;             (quotes-around (graphviz-color-string value scheme range))
;;           ""))
;;     (quotes-around value)))

;; (defun edge--process-matrix-value (value attr option seq)
;;   "Given a VALUE from a graph matrix, a Graphviz attribute, ATTR, an ini file
;; OPTION, and an archaeological sequence, SEQ, return a properly formatted
;; Graphviz dot value."
;;   (let ((range (fset:range (fset:@ (archaeological-sequence-classifiers seq)
;;                                    option))))
;;     (cond
;;      ((string= attr "style")
;;       (quotes-around (graphviz-edge-style value)))
;;      ((fset:contains? (fset:set "color" "fontcolor")
;;                       attr)
;;       (quotes-around (graphviz-color-string value
;;                                             (get-option (archaeological-sequence-configuration seq)
;;                                                         "Graphviz sequence edge attributes"
;;                                                         "colorscheme")
;;                                             (1+ (- (fset:greatest range)
;;                                                    (fset:least range))))))
;;      ((string= attr "penwidth")
;;       (let ((interval (- (get-option (archaeological-sequence-configuration seq)
;;                                      "Graphviz sequence edge attributes"
;;                                      "penwidth-max"
;;                                      :type :number)
;;                          (get-option (archaeological-sequence-configuration seq)
;;                                      "Graphviz sequence edge attributes"
;;                                      "penwidth-min"
;;                                      :type :number)))
;;             (base (get-option (archaeological-sequence-configuration seq)
;;                               "Graphviz sequence edge attributes"
;;                               "penwidth-min"
;;                               :type :number)))
;;         (quotes-around (+ base
;;                           (* value
;;                              (/ interval
;;                                 (1+ (- (fset:greatest range)
;;                                        (fset:least range))))))))))))

;; (defun node--process-matrix-value (value attr option seq)
;;   "Given a VALUE from a graph matrix, a Graphviz attribute, ATTR, an ini file
;; OPTION, and an archaeological sequence, SEQ, return a properly formatted
;; Graphviz dot value."
;;   (let ((range (fset:range (fset:@ (archaeological-sequence-classifiers seq)
;;                                    option))))
;;     (cond
;;      ((string= attr "shape")
;;       (quotes-around (graphviz-node-shape value)))
;;      ((string= attr "style")
;;       (quotes-around (graphviz-node-style value)))
;;      ((fset:contains? (fset:set "color" "fillcolor" "fontcolor")
;;                       attr)
;;       (let ((scheme (get-option (archaeological-sequence-configuration seq)
;;                                 "Graphviz sequence node attributes"
;;                                 "colorscheme")))
;;         (quotes-around (graphviz-color-string value
;;                                               scheme
;;                                               (1+ (- (fset:greatest range)
;;                                                      (fset:least range)))))))
;;      ((string= attr "penwidth")
;;       (let ((interval (- (get-option (archaeological-sequence-configuration seq)
;;                                      "Graphviz sequence node attributes"
;;                                      "penwidth-max"
;;                                      :type :number)
;;                          (get-option (archaeological-sequence-configuration seq)
;;                                      "Graphviz sequence node attributes"
;;                                      "penwidth-min"
;;                                      :type :number)))
;;             (base (get-option (archaeological-sequence-configuration seq)
;;                               "Graphviz sequence node attributes"
;;                               "penwidth-min"
;;                               :type :number)))
;;         (quotes-around (+ base
;;                           (* value
;;                              (/ interval
;;                                 (1+ (- (fset:greatest range)
;;                                        (fset:least range))))))))))))

;; (lol:defmacro! <-dot-edge (o!seq classifier dot-attr)
;;   "Make functions to configure Graphviz edges."
;;   `(let* ((g!cfg (archaeological-sequence-configuration ,g!seq))
;;           (g!graph (archaeological-sequence-graph ,g!seq))
;;           (g!classifiers (archaeological-sequence-classifiers ,g!seq))
;;           (g!attribute ,dot-attr)
;;           (g!map (make-edge-lookup-map g!cfg))
;;           (g!class-with-node (graphviz-edge-classification g!cfg "classify"))
;;           (g!value (when ,classifier (sequence-classifier g!cfg ,classifier))))
;;      (if (or (not ,classifier) (and ,classifier (emptyp g!value))
;;              (not (fset:domain-contains? g!classifiers g!value)))
;;          (let ((g!y (process-user-value
;;                    (lookup-option g!map g!attribute) g!attribute g!value ,g!seq)))
;;            (constantly (if (emptyp g!y) "" g!y)))
;;        (cond
;;         ((string= "units" g!value)
;;          (lambda (x)
;;            (let ((g!user-value
;;                    (if (= 0 (round (fset:@ (fset:@ g!classifiers g!value)
;;                                            (if (string= "to" g!class-with-node)
;;                                                (nth 1 x)
;;                                                (nth 0 x)))))
;;                        (lookup-option g!map g!value ,classifier "deposit")
;;                        (lookup-option g!map g!value ,classifier "interface"))))
;;              (if g!user-value
;;                  (process-user-value g!user-value ,dot-attr g!value
;;                                      ,o!seq :element :edge)
;;                  (error "Unable to set edge function.  User value not set for ~s.~&"
;;                         ,classifier)))))
;;         ((string= "adjacent" g!value)
;;          (lambda (x)
;;            (let ((g!user-value
;;                    (case (round (fset:@ (fset:@ g!classifiers g!value)
;;                                         (if (string= "to" g!class-with-node)
;;                                             (nth 1 x)
;;                                             (nth 0 x))))
;;                      (0 (lookup-option g!map g!value ,classifier "origin"))
;;                      (1 (lookup-option g!map g!value ,classifier "adjacent"))
;;                      (t (lookup-option g!map g!value ,classifier "not-adjacent")))))
;;              (if g!user-value
;;                  (process-user-value g!user-value ,dot-attr g!value
;;                                      ,o!seq :element :edge)
;;                (error "Unable to set edge function.  User value not set for ~s.~&"
;;                       ,classifier)))))
;;         ((string= "reachable" g!value)
;;          (lambda (x)
;;            (let ((g!user-value
;;                    (case (round (fset:@ (fset:@ g!classifiers g!value)
;;                                         (if (string= "to" g!class-with-node)
;;                                             (nth 1 x)
;;                                             (nth 0 x))))
;;                      (0 (lookup-option g!map g!value ,classifier "origin"))
;;                      (1 (lookup-option g!map g!value ,classifier "adjacent"))
;;                      (2 (lookup-option g!map g!value ,classifier "reachable"))
;;                      (t (lookup-option g!map g!value ,classifier "not-reachable")))))
;;              (if g!user-value
;;                  (process-user-value g!user-value ,dot-attr g!value
;;                                      ,o!seq :element :edge)
;;                (error "Unable to set edge function.  User value not set for ~s.~&"
;;                       ,classifier)))))
;;         ((fset:contains? (fset:set "distance" "levels" "periods" "phases")
;;                          g!value)
;;          (lambda (x)
;;            (edge--process-matrix-value
;;             (fset:@ (fset:@ g!classifiers g!value)
;;                     (if (string= "to" g!class-with-node)
;;                         (nth 1 x)
;;                         (nth 0 x)))
;;             ,dot-attr
;;             g!value
;;             ,o!seq)))
;;         (t (error "Error: Unable to set edge function.~&"))))))

;; (lol:defmacro! <-dot-node (o!seq classifier dot-attr)
;;   `(let* ((g!sequence ,g!seq)
;;           (g!opt ,classifier)
;;           (g!attribute ,dot-attr)
;;           (g!cfg (archaeological-sequence-configuration ,g!seq))
;;           (g!classifiers (archaeological-sequence-classifiers ,g!seq))
;;           (g!value (when ,classifier (sequence-classifier g!cfg ,classifier)))
;;           (map (make-node-lookup-map g!cfg)))
;;      (if (or (not g!opt) (and g!opt (emptyp g!value))
;;              (not (fset:domain-contains? g!classifiers g!value)))
;;          (let ((g!y (process-user-value (lookup-option map g!attribute)
;;                                       g!attribute g!opt g!sequence)))
;;            (constantly (if (emptyp g!y) "" g!y)))
;;        (cond
;;         ((string= "units" g!value)
;;          (lambda (x)
;;            (let ((g!user-value
;;                    (if (= 0 (round (fset:@ (fset:@ g!classifiers g!value) x)))
;;                        (lookup-option map g!value g!opt "deposit")
;;                        (lookup-option map g!value g!opt "interface"))))
;;              (if (emptyp g!user-value)
;;                  (error "Unable to set node function.  User value not set for ~s.~&"
;;                         g!opt)
;;                  (let ((g!user-value-parsed
;;                          (parse-integer g!user-value :junk-allowed t)))
;;                    (process-user-value
;;                     (if g!user-value-parsed g!user-value-parsed g!user-value)
;;                     g!attribute g!value g!sequence :element :node))))))
;;         ((string= "adjacent" g!value)
;;          (lambda (x)
;;            (let ((g!user-value
;;                    (case (round (fset:@ (fset:@ g!classifiers g!value) x))
;;                      (0 (lookup-option map g!value g!opt "origin"))
;;                      (1 (lookup-option map g!value g!opt "adjacent"))
;;                      (t (lookup-option map g!value g!opt "not-adjacent")))))
;;              (if (emptyp g!user-value)
;;                  (error "Unable to set node function.  User value not set for ~s.~&"
;;                         g!opt)
;;                  (let ((g!user-value-parsed
;;                          (parse-integer g!user-value :junk-allowed t)))
;;                    (process-user-value
;;                     (if g!user-value-parsed g!user-value-parsed g!user-value)
;;                     g!attribute g!value g!sequence :element :node))))))
;;         ((string= "reachable" g!value)
;;          (lambda (x)
;;            (let ((g!user-value
;;                    (case (round (fset:@ (fset:@ g!classifiers g!value) x))
;;                      (0 (lookup-option map g!value g!opt "origin"))
;;                      (1 (lookup-option map g!value g!opt "adjacent"))
;;                      (2 (lookup-option map g!value g!opt "reachable"))
;;                      (t (lookup-option map g!value g!opt "not-reachable")))))
;;              (if (emptyp g!user-value)
;;                  (error "Unable to set node function.  User value not set for ~s.~&"
;;                         g!opt)
;;                  (let ((g!user-value-parsed
;;                          (parse-integer g!user-value :junk-allowed t)))
;;                    (process-user-value
;;                     (if g!user-value-parsed g!user-value-parsed g!user-value)
;;                     g!attribute g!value g!sequence :element :node))))))
;;         ((fset:contains? (fset:set "distance" "levels" "periods" "phases")
;;                          g!value)
;;          (lambda (x)
;;            (node--process-matrix-value (fset:@ (fset:@ g!classifiers g!value) x)
;;                                        g!attribute g!value g!sequence)))
;;         (t (error "Error: Unable to set node function.~&"))))))
